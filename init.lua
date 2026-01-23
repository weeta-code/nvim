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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "term://*",
  command = "startinsert",
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
map("t", "<C-h>", "<C-\\><C-n><cmd>wincmd h<CR>", { silent = true, desc = "Window left" })
map("t", "<C-j>", "<C-\\><C-n><cmd>wincmd j<CR>", { silent = true, desc = "Window down" })
map("t", "<C-k>", "<C-\\><C-n><cmd>wincmd k<CR>", { silent = true, desc = "Window up" })
map("t", "<C-l>", "<C-\\><C-n><cmd>wincmd l<CR>", { silent = true, desc = "Window right" })


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
  "tpope/vim-fugitive",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "onsails/lspkind.nvim",
  "lervag/vimtex",
  "ThePrimeagen/harpoon",
  "folke/flash.nvim",
  "stevearc/quicker.nvim",
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "nvim-neotest/nvim-nio",
  "stevearc/oil.nvim",
  "stevearc/aerial.nvim",
  "sindrets/diffview.nvim",
  "NickvanDyke/opencode.nvim",

  -- Colorscheme
  "catriverr/inrainbows.vim",
}

for _, repo in ipairs(plugins) do
  if repo == "nvim-telescope/telescope-fzf-native.nvim" then
    ensure(repo, run_make)
  else
    ensure(repo)
  end
end

-- Colorscheme
vim.cmd.colorscheme("inrainbows")
vim.api.nvim_set_hl(0, "Comment", {
  fg = "#9aa0a6", -- lighter, readable
  italic = false
})

vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "LspReferenceText", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "Search", { bg = "#9aa0a6", fg = "#FFFFFF" })
vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#7a7a7a" })

-- UI plugins
require("nvim-web-devicons").setup({ default = true })
require("lualine").setup({})
require("bufferline").setup({ options = { mode = "tabs", separator_style = "slant" } })
require("ibl").setup({ indent = { char = "┊" } })
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = { delay = 100, virt_text_pos = "eol" },
})
require("dressing").setup()

-- Diffview (IDE-like diff viewer)
require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    default = { layout = "diff2_horizontal" },
    merge_tool = { layout = "diff3_mixed" },
  },
})

-- Git workflow keymaps (<leader>g prefix)
local gs = require("gitsigns")

-- Hunk navigation (bracket-style)
map("n", "]g", gs.next_hunk, { desc = "Next hunk" })
map("n", "[g", gs.prev_hunk, { desc = "Prev hunk" })

-- Gitsigns operations
map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
map("n", "<leader>gb", gs.blame_line, { desc = "Blame line (full)" })
map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, { desc = "Blame line (popup)" })

-- Visual mode hunk operations
map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selection" })
map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset selection" })

-- Diffview operations
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diff view (index)" })
map("n", "<leader>gD", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Diff vs last commit" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<CR>", { desc = "Branch history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" })

-- Fugitive operations
map("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
map("n", "<leader>gP", "<cmd>Git push<CR>", { desc = "Git push" })
map("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git pull" })
map("n", "<leader>gL", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
map("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Toggle maximizer" })

-- DAP
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
map("n", "<leader>du", function() dapui.toggle() end, { desc = "Toggle DAP UI" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function() dap.continue() end, { desc = "Continue" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "Step into" })
map("n", "<leader>do", function() dap.step_over() end, { desc = "Step over" })
map("n", "<leader>dO", function() dap.step_out() end, { desc = "Step out" })
map("n", "<leader>dr", function() dap.repl.open() end, { desc = "Open REPL" })
map("n", "<leader>dl", function() dap.run_last() end, { desc = "Run last" })
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
    natural_order = true,
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

-- Aerial (code outline/symbol navigation)
require("aerial").setup({
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = {
    max_width = { 40, 0.2 },
    min_width = 20,
    default_direction = "prefer_right",
  },
  attach_mode = "global",
  close_on_select = false,
  show_guides = true,
  filter_kind = false,
  keymaps = {
    ["?"] = "actions.show_help",
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.jump",
    ["<C-v>"] = "actions.jump_vsplit",
    ["<C-s>"] = "actions.jump_split",
    ["<C-p>"] = "actions.scroll",
    ["<C-j>"] = "actions.down_and_scroll",
    ["<C-k>"] = "actions.up_and_scroll",
    ["{"] = "actions.prev",
    ["}"] = "actions.next",
    ["[["] = "actions.prev_up",
    ["]]"] = "actions.next_up",
    ["q"] = "actions.close",
    ["o"] = "actions.tree_toggle",
    ["O"] = "actions.tree_toggle_recursive",
    ["l"] = "actions.tree_open",
    ["h"] = "actions.tree_close",
    ["zR"] = "actions.tree_open_all",
    ["zM"] = "actions.tree_close_all",
  },
})
-- Aerial keymaps (leader-based)
map("n", "<leader>aa", "<cmd>AerialToggle!<CR>", { desc = "Toggle aerial" })
map("n", "<leader>af", "<cmd>AerialToggle float<CR>", { desc = "Aerial float" })
map("n", "<leader>an", "<cmd>AerialNavToggle<CR>", { desc = "Aerial nav" })
-- Symbol navigation (bracket-style like [d ]d for diagnostics)
map("n", "[s", "<cmd>AerialPrev<CR>", { desc = "Prev symbol" })
map("n", "]s", "<cmd>AerialNext<CR>", { desc = "Next symbol" })
map("n", "[[", "<cmd>AerialPrevUp<CR>", { desc = "Prev symbol (up)" })
map("n", "]]", "<cmd>AerialNextUp<CR>", { desc = "Next symbol (up)" })

-- Floaterminal
local floaterm = { buf = nil, win = nil }

local function floaterm_open(fresh)
  -- Kill old buffer if fresh requested or buffer invalid
  if fresh or (floaterm.buf and not vim.api.nvim_buf_is_valid(floaterm.buf)) then
    if floaterm.buf and vim.api.nvim_buf_is_valid(floaterm.buf) then
      vim.api.nvim_buf_delete(floaterm.buf, { force = true })
    end
    floaterm.buf, floaterm.win = nil, nil
  end

  -- Close if already open
  if floaterm.win and vim.api.nvim_win_is_valid(floaterm.win) then
    vim.api.nvim_win_close(floaterm.win, true)
    floaterm.win = nil
    return
  end

  -- Create buffer if needed
  if not floaterm.buf or not vim.api.nvim_buf_is_valid(floaterm.buf) then
    floaterm.buf = vim.api.nvim_create_buf(false, true)
  end

  -- Dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  floaterm.win = vim.api.nvim_open_win(floaterm.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  -- Start terminal if buffer is empty
  if vim.bo[floaterm.buf].buftype ~= "terminal" then
    vim.cmd("terminal")
  end
  vim.cmd("startinsert")
end

map("n", "<leader>tt", function() floaterm_open(false) end, { desc = "Toggle terminal" })
map("n", "<leader>tn", function() floaterm_open(true) end, { desc = "New terminal" })
map("t", "<C-q>", function() floaterm_open(false) end, { desc = "Close terminal" })

map("n", "<leader>oa", function() require('opencode').ask() end, { desc = "opencode ask"})
map("n", "<leader>os", function() require('opencode').select() end, { desc = "opencode select"})
map("n", "<leader>oo", function() require('opencode').operator() end, { desc = "opencode operator"})

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
vim.keymap.set({ "n", "x", "o" }, "m", function() flash.jump() end)
vim.keymap.set({ "n", "x", "o" }, "M", function() flash.treesitter() end)
vim.keymap.set("o", "r", function() flash.remote() end)
vim.keymap.set({ "x", "o" }, "R", function() flash.treesitter_search() end)
vim.keymap.set({ "c" }, "<c-s>", function() flash.toggle() end)

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

-- Treesitter: Neovim 0.11+ has built-in support
-- Bundled parsers: c, lua, markdown, markdown_inline, query, vim, vimdoc
-- Use nvim-treesitter only for installing additional parsers

-- Enable treesitter highlighting for all buffers
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Parser management (using nvim-treesitter if available)
local ts_ok, ts = pcall(require, "nvim-treesitter")
if ts_ok then
  -- Core parsers you want installed (beyond the bundled ones)
  -- Note: swift/latex are slow to compile (need grammar generation), install manually if needed
  local wanted_parsers = {
    "bash", "cpp", "css", "dockerfile", "go", "gomod", "html", "javascript",
    "json", "python", "tsx", "typescript", "yaml",
  }

  -- Check if a parser is installed by looking for its .so file
  local function parser_installed(lang)
    local paths = vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false)
    return #paths > 0
  end

  -- Auto-install missing parsers on startup
  vim.defer_fn(function()
    local missing = {}
    for _, lang in ipairs(wanted_parsers) do
      if not parser_installed(lang) then
        table.insert(missing, lang)
      end
    end
    if #missing > 0 then
      vim.notify("Installing missing parsers: " .. table.concat(missing, ", "), vim.log.levels.INFO)
      ts.install(missing)
    end
  end, 500)

  -- User commands
  vim.api.nvim_create_user_command("TSInstall", function(opts)
    ts.install(opts.fargs)
  end, { nargs = "+", desc = "Install treesitter parser(s)" })

  vim.api.nvim_create_user_command("TSInstallAll", function()
    vim.notify("Installing parsers: " .. table.concat(wanted_parsers, ", "), vim.log.levels.INFO)
    ts.install(wanted_parsers)
  end, { desc = "Install all wanted parsers" })

  vim.api.nvim_create_user_command("TSInstallInfo", function()
    local installed, not_installed = {}, {}
    for _, lang in ipairs(wanted_parsers) do
      if parser_installed(lang) then
        table.insert(installed, lang)
      else
        table.insert(not_installed, lang)
      end
    end
    print("Installed: " .. (#installed > 0 and table.concat(installed, ", ") or "none"))
    print("Missing: " .. (#not_installed > 0 and table.concat(not_installed, ", ") or "none"))
  end, { desc = "Show parser install status" })
end

-- Autopairs
require("nvim-autopairs").setup()

-- Completion
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
  completion = { completeopt = "menu,menuone,preview,noselect" },
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

-- LSP server configs (Neovim 0.11+ native)
vim.lsp.config('clangd', {
  capabilities = capabilities,
  cmd = { "clangd", "--offset-encoding=utf-16" },
})

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
})

vim.lsp.config('sourcekit', {
  capabilities = capabilities,
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift", "objective-c", "objective-cpp" },
  root_markers = { "Package.swift", ".git", ".sourcekit-lsp" },
})

vim.lsp.config('ts_ls', { capabilities = capabilities })
vim.lsp.config('pyright', { capabilities = capabilities })
vim.lsp.config('gopls', { capabilities = capabilities })

-- Enable LSP servers (auto-attaches on matching filetypes)
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
vim.lsp.enable('sourcekit')
vim.lsp.enable('ts_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('gopls')

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
