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
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. repo .. ".git", path })
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
require("flexoki").setup({ theme = "dragon", background = { dark = "dragon", light = "lotus" } })
vim.cmd.colorscheme("flexoki-dark")

-- UI plugins
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

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash", "css", "dockerfile", "go", "gomod", "json", "javascript", "typescript", "lua", "vim",
    "python", "tsx", "yaml", "markdown", "markdown_inline", "html", "latex", "svelte",
  },
  highlight = { enable = true },
  indent = { enable = true },
  autotag = { enable = true },
})

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

-- LSP
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local servers = { "lua_ls", "tsserver", "pyright", "gopls", "clangd" }

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
  local opts = { capabilities = capabilities }
  if server == "clangd" then
    opts.cmd = { "clangd", "--offset-encoding=utf-16" }
  elseif server == "lua_ls" then
    opts.settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } }
  end
  lspconfig[server].setup(opts)
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

-- Copilot
vim.g.copilot_no_tab_map = true
map("i", "<C-h>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
map("i", "<C-j>", "<Plug>(copilot-next)")
map("i", "<C-k>", "<Plug>(copilot-previous)")
map("i", "<C-l>", "<Plug>(copilot-dismiss)")

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
