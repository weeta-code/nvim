vim.loader.enable()

-- Leader and basics
vim.g.mapleader = " "

vim.cmd("let g:netrw_liststyle = 3")
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = "jql"
  end,
})

local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
vim.g.have_nerd_font = true

-- Keymaps
local map = vim.keymap.set
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
map("n", "<leader>+", "<C-a>", { desc = "Increment number" })
map("n", "<leader>-", "<C-x>", { desc = "Decrement number" })
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Prev tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Buffer in tab" })

-- Native package manager bootstrap
local pack_root = vim.fn.stdpath("data") .. "/site/pack/plugins/start"
vim.fn.mkdir(pack_root, "p")

local function ensure(repo, build)
  local name = repo:match("[^/]+$")
  local path = pack_root .. "/" .. name
  if not vim.loop.fs_stat(path) then
    vim.system({ "git", "clone", "--depth=1", "https://github.com/" .. repo .. ".git", path }):wait()
    if build then
      build(path)
    end
  end
  pcall(vim.cmd.packadd, name)
  return path
end

local function run_make(path)
  vim.fn.system({ "bash", "-c", "cd " .. path .. " && make" })
end

local plugins = {
  "nvim-lua/plenary.nvim",
  "christoomey/vim-tmux-navigator",
  "nvim-tree/nvim-web-devicons",
  "nvim-tree/nvim-tree.lua",
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-fzf-native.nvim",
  "nvim-treesitter/nvim-treesitter",
  "windwp/nvim-ts-autotag",
  "windwp/nvim-autopairs",
  "nvim-lualine/lualine.nvim",
  "akinsho/bufferline.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "lewis6991/gitsigns.nvim",
  "folke/trouble.nvim",
  "folke/which-key.nvim",
  "goolord/alpha-nvim",
  "rmagatti/auto-session",
  "stevearc/dressing.nvim",
  "szw/vim-maximizer",
  "kepano/flexoki-neovim",
  "tpope/vim-fugitive",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",
  "onsails/lspkind.nvim",
  "neovim/nvim-lspconfig",
  "github/copilot.vim",
  "lervag/vimtex",

  -- Colorscheme
  "vague-theme/vague.nvim",
}

for _, repo in ipairs(plugins) do
  if repo == "nvim-telescope/telescope-fzf-native.nvim" then
    ensure(repo, run_make)
  elseif repo == "L3MON4D3/LuaSnip" then
    ensure(repo, function(path)
      vim.fn.system({ "bash", "-c", "cd " .. path .. " && make install_jsregexp" })
    end)
  else
    ensure(repo)
  end
end

-- Colorscheme
-- Installed via the manual pack bootstrap above (repo: vague-theme/vague.nvim).
-- The directory name is `vague.nvim`, so that's what `packadd` expects.
pcall(vim.cmd.packadd, "vague.nvim")
require("vague").setup({})
vim.cmd.colorscheme("vague")

-- UI plugins
require("nvim-web-devicons").setup({ default = true })
require("lualine").setup({})
require("bufferline").setup({ options = { mode = "tabs", separator_style = "slant" } })
require("ibl").setup({ indent = { char = "┊" } })
require("gitsigns").setup()
require("dressing").setup()
map("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Toggle maximizer" })

-- File explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
  view = { width = 35, relativenumber = true },
  filters = { custom = { ".DS_Store" } },
  git = { ignore = false },
  update_focused_file = { enable = true, update_root = true },
})
map("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Find file in explorer" })
map("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse explorer" })
map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh explorer" })

-- Auto-focus NvimTree on the directory of the current buffer
local function _nvimtree_focus_current_dir()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return
  end

  -- Ignore special/unnamed buffers
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" then
    return
  end

  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return
  end

  -- Ensure NvimTree root follows the active file, then focus the entry
  pcall(api.tree.change_root_to_node, vim.fn.fnamemodify(file, ":p:h"))
  pcall(api.tree.find_file, file)

  -- If the tree is visible, focus it
  local view_ok, view = pcall(require, "nvim-tree.view")
  if view_ok and view.is_visible() then
    pcall(api.tree.focus)
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  callback = _nvimtree_focus_current_dir,
})

-- Telescope
local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
  defaults = {
    path_display = { "smart" },
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
})
pcall(telescope.load_extension, "fzf")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Grep word" })

local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if ts_ok then
  ts_configs.setup({
    ensure_installed = {
      "bash", "css", "dockerfile", "go", "gomod", "json", "javascript", "typescript", "lua", "vim",
      "python", "tsx", "yaml", "markdown", "markdown_inline", "html", "latex", "svelte",
    },
    highlight = { enable = true },
    indent = { enable = true },
    autotag = { enable = true },
  })
end

-- Autopairs
require("nvim-autopairs").setup()

-- Completion
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  completion = { completeopt = "menu,menuone,preview,noselect" },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-l>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
  formatting = { format = lspkind.cmp_format({ maxwidth = 50, ellipsis_char = "..." }) },
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- LSP (Neovim 0.11+)
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- `vim.lsp.config` keys use underscores, not hyphens (e.g. `sourcekit_lsp`)
local servers = { "sourcekit_lsp", "lua_ls", "ts_ls", "pyright", "gopls", "clangd" }

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

map("n", "[d", function()
  vim.diagnostic.goto_prev()
  vim.diagnostic.open_float(nil, { focus = false })
end)
map("n", "]d", function()
  vim.diagnostic.goto_next()
  vim.diagnostic.open_float(nil, { focus = false })
end)

for _, server in ipairs(servers) do
  local cfg = vim.deepcopy(vim.lsp.config[server] or {})
  cfg.capabilities = capabilities

  if server == "clangd" then
    cfg.cmd = { "clangd", "--offset-encoding=utf-16" }
  elseif server == "lua_ls" then
    cfg.settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } }
  elseif server == "sourcekit_lsp" then
    cfg.cmd = { "sourcekit-lsp" }
    cfg.filetypes = { "swift", "objective-c", "objective-cpp" }
    cfg.root_markers = { "Package.swift", ".git", ".sourcekit-lsp" }
    cfg.capabilities.workspace = cfg.capabilities.workspace or {}
    cfg.capabilities.textDocument = cfg.capabilities.textDocument or {}
    cfg.capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
    cfg.root_dir = function(fname)
      return vim.fs.root(fname, { "Package.swift", ".git", ".sourcekit-lsp" })
    end
  end

  vim.lsp.start(cfg)
end

-- Trouble and helpers
require("trouble").setup({ focus = true })
map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Workspace diagnostics" })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
map("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Quickfix" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "Todos" })

require("which-key").setup({})

-- Session management
require("auto-session").setup({ auto_restore_enabled = false })
map("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session" })
map("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session" })

-- Dashboard
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {
  " ▄█     █▄     ▄████████    ▄████████     ███        ▄████████ ",
  " ███     ███   ███    ███   ███    ███ ▀█████████▄   ███    ███ ",
  " ███     ███   ███    █▀    ███    █▀     ▀███▀▀██   ███    ███ ",
  " ███     ███  ▄███▄▄▄      ▄███▄▄▄         ███   ▀   ███    ███ ",
  " ███     ███ ▀▀███▀▀▀     ▀▀███▀▀▀         ███     ▀███████████ ",
  " ███     ███   ███    █▄    ███    █▄      ███       ███    ███ ",
  " ███ ▄█▄ ███   ███    ███   ███    ███     ███       ███    ███ ",
  "  ▀███▀███▀    ██████████   ██████████    ▄████▀     ███    █▀  ",
}

dashboard.section.buttons.val = {
  dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
  dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
  dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
  dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
  dashboard.button("SPC wr", "󰁯  > Restore Session", "<cmd>SessionRestore<CR>"),
  dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
}

alpha.setup(dashboard.opts)
vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

-- Copilot (github/copilot.vim)
-- How it works:
-- - Copilot shows inline "ghost text" suggestions while you type.
-- - Accept with <C-h>, cycle with <C-j>/<C-k>, dismiss with <C-l>.
-- - To "ask it" for something, you generally prompt it by writing code/comments
--   describing what you want, then pause briefly for a suggestion.
--
-- Ensure Copilot is enabled by default and don't map <Tab>.
vim.g.copilot_enabled = 1
vim.g.copilot_no_tab_map = true

-- Recommended: keep Copilot from taking over completion menu behavior.
vim.g.copilot_assume_mapped = true

-- Inline suggestion controls
map("i", "<C-h>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, desc = "Copilot accept" })
map("i", "<C-j>", "<Plug>(copilot-next)", { desc = "Copilot next suggestion" })
map("i", "<C-k>", "<Plug>(copilot-previous)", { desc = "Copilot previous suggestion" })
map("i", "<C-l>", "<Plug>(copilot-dismiss)", { desc = "Copilot dismiss suggestion" })

-- Useful commands / status helpers
map("n", "<leader>ce", "<cmd>Copilot enable<CR>", { desc = "Copilot enable" })
map("n", "<leader>cd", "<cmd>Copilot disable<CR>", { desc = "Copilot disable" })
map("n", "<leader>cs", "<cmd>Copilot status<CR>", { desc = "Copilot status" })

-- Vimtex
vim.g.tex_flavor = "latex"
vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_progname = "nvr"
vim.g.vimtex_compiler_start_on_open = 1
vim.g.vimtex_compiler_latexmk = {
  continuous = 1,
  build_dir = "build",
  aux_dir = "build",
  out_dir = "build",
  options = {
    "-pdf",
    "-interaction=nonstopmode",
    "-synctex=1",
    "-file-line-error",
    "-shell-escape",
    "-outdir=build",
    "-auxdir=build",
  },
}
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_complete_close_braces = 1
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = { "*.tex" },
  callback = function()
    vim.cmd("silent! update")
  end,
})
