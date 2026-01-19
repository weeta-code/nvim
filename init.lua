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
-- opt.relativenumber = true
opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = false
opt.background = "dark"
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
-- vim.g.have_nerd_font = true

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
  "lervag/vimtex",
  "pechorin/any-jump.vim",
  "ThePrimeagen/harpoon",
  "folke/flash.nvim",
  "stevearc/quicker.nvim",
  "mfussenegger/nvim-dap",
  "stevearc/oil.nvim",

  -- Colorscheme
  "catriverr/inrainbows.vim",
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
vim.cmd.colorscheme("inrainbows")
vim.api.nvim_set_hl(0, "Comment", {
  fg = "#9aa0a6",   -- lighter, readable
  italic = false
})

vim.api.nvim_set_hl(0, "LspReferenceRead", {fg = "#FF0000"})
vim.api.nvim_set_hl(0, "LspReferenceWrite", {fg = "#FF0000"})
vim.api.nvim_set_hl(0, "LspReferenceText", {fg = "#FF0000"})
vim.api.nvim_set_hl(0, "Search", { bg = "#9aa0a6", fg = "#FFFFFF" })

-- UI plugins
require("nvim-web-devicons").setup({ default = true })
require("lualine").setup({})
require("bufferline").setup({ options = { mode = "tabs", separator_style = "slant" } })
require("ibl").setup({ indent = { char = "┊" } })
require("gitsigns").setup()
require("dressing").setup()
map("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Toggle maximizer" })

-- DAP
local dap = require("dap")
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args = {}, -- provide arguments if needed
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Select and attach to process",
    type = "gdb",
    request = "attach",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    pid = function()
      local name = vim.fn.input('Executable name (filter): ')
      return require("dap.utils").pick_process({ filter = name })
    end,
    cwd = '${workspaceFolder}'
  },
  {
    name = 'Attach to gdbserver :1234',
    type = 'gdb',
    request = 'attach',
    target = 'localhost:1234',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}'
  }
}

-- Oil
require("oil").setup({
  default_file_explorer = true,
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    "mtime",
  },
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  prompt_save_on_select_new_entry = true,
  cleanup_delay_ms = 2000,
  lsp_file_methods = {
    enabled = true,
    timeout_ms = 1000,
    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    autosave_changes = true,
  },
  constrain_cursor = "editable",
  watch_for_changes = true,
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,
  view_options = {
    show_hidden = true,
    is_hidden_file = function(name, bufnr)
      local m = name:match("^%.")
      return m ~= nil
    end,
    is_always_hidden = function(name, bufnr)
      return false
    end,
    -- Sort file names with numbers in a more intuitive order for humans.
    -- Can be "fast", true, or false. "fast" will turn it off for large directories.
    natural_order = "true",
    case_insensitive = false,
    sort = {
      { "type", "asc" },
      { "name", "asc" },
    },
    -- Customize the highlight group for the file name
    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
      return nil
    end,
  },
  extra_scp_args = {},
  extra_s3_args = {},
  git = {
    add = function(path)
      return true
    end,
    mv = function(src_path, dest_path)
      return true
    end,
    rm = function(path)
      return true
    end,
  },
  -- Configuration for the floating window in oil.open_float
  float = {
    padding = 2,
    max_width = 0.4,
    max_height = 0.6,
    border = nil,
    win_options = {
      winblend = 0,
    },
    get_win_title = nil,
    -- preview_split: Split direction: "auto", "left", "right", "above", "below".
    preview_split = "auto",
    override = function(conf)
      return conf
    end,
  },
  preview_win = {
    update_on_cursor_moved = true,
    preview_method = "fast_scratch",
    -- A function that returns true to disable preview on a file e.g. to avoid lag
    disable_preview = function(filename)
      return false
    end,
    -- Window-local options to use for preview window buffers
    win_options = {},
  },
  -- Configuration for the floating action confirmation window
  confirmation = {
    -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_width and max_width can be a single value or a list of mixed integer/float types.
    -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
    max_width = 0.9,
    -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
    min_width = { 40, 0.4 },
    -- optionally define an integer/float for the exact width of the preview window
    width = nil,
    -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    -- min_height and max_height can be a single value or a list of mixed integer/float types.
    -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
    max_height = 0.9,
    -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
    min_height = { 5, 0.1 },
    -- optionally define an integer/float for the exact height of the preview window
    height = nil,
    border = nil,
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating progress window
  progress = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = { 10, 0.9 },
    min_height = { 5, 0.1 },
    height = nil,
    border = nil,
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
  -- Configuration for the floating SSH window
  ssh = {
    border = nil,
  },
  -- Configuration for the floating keymaps help window
  keymaps_help = {
    border = nil,
  },
})

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup({})
vim.keymap.set("n", "<leader>h;", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end)

-- Quicker
require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
vim.keymap.set("n", "<leader>q", function()
  require("quicker").toggle()
end, {
  desc = "Toggle quickfix",
})
vim.keymap.set("n", "<leader>l", function()
  require("quicker").toggle({ loclist = true })
end, {
  desc = "Toggle loclist",
})

-- Flash
local flash = require("flash")
vim.keymap.set({"n", "x", "o"}, "m", function() flash:jump() end)
vim.keymap.set({"n", "x", "o"}, "M", function() flash:treesitter() end)
vim.keymap.set("o", "r", function() flash:remote() end)
vim.keymap.set({"x", "o"}, "R", function() flash:treesitter_search() end)
vim.keymap.set({"c"}, "<c-s>", function() flash:toggle() end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end)
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end)

-- File explorer (Oil)
map("n", "<leader>ee", "<cmd>Oil --float<CR>", { desc = "Open Oil (floating)" })
map("n", "<leader>ef", "<cmd>Oil<CR>", { desc = "Open Oil (full screen)" })

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
      "python", "tsx", "yaml", "markdown", "markdown_inline", "html", "latex", "svelte", "c", "cpp"
    },
    highlight = { enable = true },
    indent = { enable = true },
    autotag = { enable = true },
  })
end

-- Autopairs
require("nvim-autopairs").setup()

--:echo nvim_get_runtime_file('parser/*.so', v:true) Completion
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

-- LSP (Neovim 0.11+ built-in)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.set_log_level("off")

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

-- Register server configs; we start/attach per-buffer below.
-- NOTE: `vim.lsp.config` keys use underscores, not hyphens.
vim.lsp.config.clangd = {
  capabilities = capabilities,
  cmd = { "clangd", "--offset-encoding=utf-16" },
}

vim.lsp.config.lua_ls = {
  capabilities = capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
}

-- sourcekit-lsp covers Swift + ObjC/ObjC++
vim.lsp.config.sourcekit_lsp = {
  capabilities = capabilities,
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift", "objective-c", "objective-cpp" },
  root_markers = { "Package.swift", ".git", ".sourcekit-lsp" },
  root_dir = function(fname)
    return vim.fs.root(fname, { "Package.swift", ".git", ".sourcekit-lsp" })
  end,
}

vim.lsp.config.ts_ls = { capabilities = capabilities }
vim.lsp.config.pyright = { capabilities = capabilities }
vim.lsp.config.gopls = { capabilities = capabilities }

-- Start/attach per buffer (avoid starting everything at init time)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype

    local function start(name, cfg)
      local final = vim.deepcopy(cfg or {})
      final.bufnr = args.buf
      vim.lsp.start(final, { name = name })
    end

    if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
      start("clangd", vim.lsp.config.clangd)
      return
    end

    if ft == "swift" or ft == "objective-c" or ft == "objective-cpp" then
      start("sourcekit_lsp", vim.lsp.config.sourcekit_lsp)
      return
    end

    if ft == "lua" then
      start("lua_ls", vim.lsp.config.lua_ls)
      return
    end

    if ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
      start("ts_ls", vim.lsp.config.ts_ls)
      return
    end

    if ft == "python" then
      start("pyright", vim.lsp.config.pyright)
      return
    end

    if ft == "go" then
      start("gopls", vim.lsp.config.gopls)
      return
    end
  end,
})

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
  dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
  dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>Oil --float<CR>"),
  dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
  dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
  dashboard.button("SPC wr", "󰁯  > Restore Session", "<cmd>SessionRestore<CR>"),
  dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
}

alpha.setup(dashboard.opts)
vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

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
