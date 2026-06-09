-- ~/.config/nvim/init.lua
-- Modernized 2026-05-01 for Neovim 0.12+. Uses native vim.pack for plugins
-- and native LSP (vim.lsp.config / vim.lsp.enable). Heavily debloated.

vim.loader.enable()

-- =============================================================================
-- Options
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_liststyle = 3
vim.g.tex_flavor = "latex"

vim.o.shell = "/bin/zsh"
vim.o.shellcmdflag = "-l -c"

local opt = vim.opt
opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
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
opt.completeopt = "menu,menuone,noinsert,fuzzy"
opt.winborder = "rounded" -- 0.11+ default border for floating windows
opt.autochdir = true
vim.filetype.add({ extension = { tex = "tex" } })

-- =============================================================================
-- Plugin manager (vim.pack — native, 0.12+)
-- =============================================================================
vim.pack.add({
  -- Core libs
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- UI
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/sphamba/smear-cursor.nvim" },
  { src = "https://github.com/OXY2DEV/markview.nvim" },

  -- Editing
  { src = "https://github.com/echasnovski/mini.nvim" }, -- mini.pairs + mini.surround
  { src = "https://github.com/folke/flash.nvim" },
  { src = "https://github.com/pechorin/any-jump.vim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/NStefan002/visual-surround.nvim" },

  -- Treesitter (parsers + queries; highlight is built-in 0.11+)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- Completion (modern blink.cmp — single plugin, includes lsp/buffer/path)
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },

  -- LaTeX
  { src = "https://github.com/lervag/vimtex" },

  -- Colorscheme
  { src = "https://github.com/oskarnurm/koda.nvim" },

  -- Fun things
  { src = "https://github.com/NicolasGB/jj.nvim" },
  { src = "https://github.com/TheNoeTrevino/haunt.nvim" },
  { src = "https://github.com/bngarren/checkmate.nvim" },
  { src = "https://github.com/SmiteshP/nvim-navic" },
  { src = "https://github.com/zk-org/zk-nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },
})

-- =============================================================================
-- Colorscheme — koda.nvim (dark variant)
-- =============================================================================
require("koda").setup({
  theme = { dark = "dark" },
  transparent = true,
  styles = {
    comments  = {},   -- no italics
    keywords  = {},
    functions = {},
    strings   = {},
    constants = {},
  },
})
require("koda").load("dark")

-- Dashboard highlight palette (Koda dark)
local hl = vim.api.nvim_set_hl
hl(0, "SnacksDashboardHeader",      { fg = "#b0b0b0" })
hl(0, "SnacksDashboardIcon",        { fg = "#b0b0b0" })
hl(0, "SnacksDashboardKey",         { fg = "#d9ba73" })
hl(0, "SnacksDashboardDesc",        { fg = "#b0b0b0" })
hl(0, "SnacksDashboardFile",        { fg = "#50585d" })
hl(0, "SnacksDashboardDir",         { fg = "#777777" })
hl(0, "SnacksDashboardTitle",       { fg = "#ffffff", bold = true })
hl(0, "SnacksDashboardSpecial",     { fg = "#458ee6" })

-- =============================================================================
-- Keymaps (basic editing)
-- =============================================================================
local map = vim.keymap.set
map("i", "jk", "<ESC>",                       { desc = "Exit insert mode" })
map("n", "<leader>nh", ":nohl<CR>",           { desc = "Clear search highlights" })
map("n", "<leader>+", "<C-a>",                { desc = "Increment number" })
map("n", "<leader>-", "<C-x>",                { desc = "Decrement number" })
map("n", "<leader>sv", "<C-w>v",              { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s",              { desc = "Split horizontally" })
map("n", "<leader>se", "<C-w>=",              { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<CR>",      { desc = "Close split" })
map("n", "<leader>to", "<cmd>tabnew<CR>",     { desc = "New tab" })
map("n", "<leader>tc", "<cmd>tabclose<CR>",   { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>",       { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>",       { desc = "Prev tab" })
-- Terminal-mode window jumps
map("t", "<C-h>", "<C-\\><C-n><cmd>wincmd h<CR>", { silent = true })
map("t", "<C-j>", "<C-\\><C-n><cmd>wincmd j<CR>", { silent = true })
map("t", "<C-k>", "<C-\\><C-n><cmd>wincmd k<CR>", { silent = true })
map("t", "<C-l>", "<C-\\><C-n><cmd>wincmd l<CR>", { silent = true })

-- Format options + auto insert in terminals
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function() vim.opt.formatoptions = "jql" end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "term://*",
  command = "startinsert",
})

-- =============================================================================
-- UI plugins
-- =============================================================================
require("nvim-web-devicons").setup({ default = true })
require("lualine").setup({
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    globalstatus = true,
  },
  sections = {
    lualine_z = {
      { "tabs", use_mode_colors = true, show_modified_status = false, mode = 1,
        fmt = function(_, ctx) return ctx.current and "" or "" end}
    },
  },
})
require("ibl").setup({ indent = { char = "┊" } })
require("which-key").setup({})

require("smear_cursor").setup({
  smear_between_buffers = true,
  smear_insert_mode = true,
  smear_between_neighbor_lines = true,
})

local navic = require("nvim-navic")

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

-- =============================================================================
-- mini.nvim (pairs + surround)
-- =============================================================================
require("mini.pairs").setup()
require("mini.surround").setup({
  -- mini.surround uses sa/sd/sr/sf/sF/sh/sn — different from vim-surround's cs/ds/ys.
  -- See `:h mini.surround` for the cheat sheet.
})

-- =============================================================================
-- flash.nvim
-- =============================================================================
local flash = require("flash")
flash.setup()
map({ "n", "x", "o" }, "m", flash.jump,                { desc = "Flash jump" })
-- map({ "n", "x", "o" }, "Mu", flash.treesitter,          { desc = "Flash treesitter" })
-- map("o",               "r", flash.remote,              { desc = "Flash remote" })
-- map({ "x", "o" },      "R", flash.treesitter_search,   { desc = "Flash treesitter search" })
-- map("c",               "<C-s>", flash.toggle,          { desc = "Flash toggle in cmdline" })

-- =============================================================================
-- oil.nvim
-- =============================================================================
require("oil").setup({
  default_file_explorer = true,
  columns = { "icon", "mtime" },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    natural_order = true,
  },
  win_options = { wrap = false, signcolumn = "no" },
  float = { padding = 2, max_width = 0.4, max_height = 0.6 },
})
map("n", "-",          function() require("oil").open() end, { desc = "Oil parent dir" })
map("n", "<leader>ee", "<cmd>Oil --float<CR>",               { desc = "Oil (floating)" })
map("n", "<leader>ef", "<cmd>Oil<CR>",                       { desc = "Oil (full)" })

-- =============================================================================
-- diffview
-- =============================================================================
require("diffview").setup({
  view = {
    default = {
      layout = "diff2_vertical",
    },
    merge_tool = {
      layout = "diff3_mixed",
    },
    file_history_view = {
      layout = "diff2_vertical"
    }
  },

})

-- =============================================================================
-- JJ
-- =============================================================================
require("jj").setup({
  picker = { snacks = {} },
  editor = {
    auto_insert = false,
    window = {
      type = "floating",
      floating_width = 0.8,
      floating_height = 0.9
    },
  },

  terminal = {
    cursor_render_delay = 10,
  },
  
  diff = {
    backend = "diffview",
  },

  keymaps = {
    -- Log buffer keymaps (set to nil to disable)
    log = {
      edit = "<CR>",                      -- Edit revision under cursor
      edit_immutable = "<S-CR>",          -- Edit revision (ignore immutability)
      describe = "d",                     -- Describe revision under cursor
      diff = "<S-d>",                     -- Diff revision under cursor
      edit = "e",                         -- Edit revision under cursor
      new = "n",                          -- Create new change branching off
      new_after = "<C-n>",                -- Create new change after revision
      new_after_immutable = "<S-n>",      -- Create new change after (ignore immutability)
      undo = "<S-u>",                     -- Undo last operation
      redo = "<S-r>",                     -- Redo last undone operation
      abandon = "a",                      -- Abandon revision under cursor
      bookmark = "b",                     -- Create or move bookmark to revision under cursor
      bookmark_del = "B",                 -- Delete bookmark of revision under cursor
      fetch = "f",                        -- Fetch from remote
      push = "p",                         -- Push bookmark of revision under cursor
      push_all = "<S-p>",                 -- Push all changes to remote
      open_pr = "o",                      -- Open PR/MR for revision under cursor
      open_pr_list = "<S-o>",             -- Open PR/MR by selecting from all bookmarks
      rebase = "r",                       -- Enter rebase mode targeting revision under cursor or selected revisions
      rebase_mode = {
        onto = { "<CR>", "o" },           -- Select revision under cursor as rebase onto destination
        after = "a",                      -- Rebase after revision under cursor
        before = "b",                     -- Rebase before revision under cursor
        onto_immutable = { "<S-CR>", "<S-o>" }, -- Select revision  as a rebase onto destination (ignore immutability)
        after_immutable = "<S-a>",              -- Rebase after revision under cursor (ignore immutability)
        before_immutable = "<S-b>",             -- Rebase before revision under cursor (ignore immutability)
        exit_mode = { "<Esc>", "<C-c>" }, -- Exit rebase mode
      },
      duplicate = "<C-y>",                -- Enter duplicate mode targeting revision under cursor or selected revisions
      duplicate_mode = {
        onto = { "<CR>", "o" },           -- Select revision under cursor as duplicate onto destination
        after = "a",                      -- Duplicate after revision under cursor
        before = "b",                     -- Duplicate before revision under cursor
        onto_immutable = { "<S-CR>", "<S-o>" }, -- Duplicate onto revision under cursor (ignore immutability)
        after_immutable = "<S-a>",              -- Duplicate after revision under cursor (ignore immutability)
        before_immutable = "<S-b>",             -- Duplicate before revision under cursor (ignore immutability)
        exit_mode = { "<Esc>", "<C-c>" }, -- Exit duplicate mode
      },
      squash = "s",                       -- Enter squash mode targeting revision under cursor or selected revisions
      squash_mode = {
        into = "<CR>",                     -- Squash into revision under cursor
        into_immutable = "<S-CR>",         -- Squash into revision under cursor (ignore immutability)
        exit_mode = { "<Esc>", "<C-c>" }, -- Exit squash mode
      },
      quick_squash = "<S-s>",             -- Quick squash revision under cursor into its parent (ignore immutability)
      split = "<C-s>",                    -- Split the revision under cursor
      history = "<S-h>",                  -- Show a history-aware diff for the selected revision range
      change_revset = "<C-r>",            -- Change the revset(s) being viewed in the log buffer
      tag_set = "<S-t>",                  -- Create a tag on the revision under cursor
      summary = "<S-k>",                  -- Show summary tooltip for revision under cursor
      select_next_revision = "gj",        -- Move cursor to the next revision in the log
      select_prev_revision = "gk",        -- Move cursor to the previous revision in the log
      summary_tooltip = {
        diff = "<S-d>",                   -- Diff file at this revision
        edit = "<CR>",                    -- Edit revision and open file
        edit_immutable = "<S-CR>",        -- Edit revision (ignore immutability) and open file
        edit_file = "o",                  -- Open the file under cursor in a new tab like `:Jtabedit` would
      },
    },
    -- Status buffer keymaps (set to nil to disable)
    status = {
      open_file = "<CR>",                 -- Open file under cursor
      restore_file = "<S-x>",             -- Restore file under cursor
    },
    -- Close keymaps (shared across all buffers)
    close = { "q", "<Esc>" },
    -- Floating buffer keymaps
    floating = {
      close = "q",                          -- Close floating buffer
      hide = "<Esc>",                       -- Hide floating buffer
    },
  },
})

-- =============================================================================
-- Haunt.nvim
-- =============================================================================
do
  local ok, project = pcall(require, "haunt.project")
  if ok then
    -- Haunt runs several git probes during UIEnter and bookmark saves. Using
    -- vim.system avoids the slow shell path behind vim.fn.systemlist().
    project.run_git = function(cmd)
      local args = vim.split(cmd, " ", { trimempty = true })
      if args[1] ~= "git" then
        return nil
      end

      local result = vim.system(args, { text = true }):wait()
      if result.code ~= 0 then
        return nil
      end

      local stdout = vim.trim(result.stdout or "")
      if stdout == "" then
        return { "" }
      end
      return vim.split(stdout, "\n", { plain = true })
    end

    -- Persistence fix: haunt keys each storage file by project identity
    -- (git root-commit -> git toplevel -> cwd), so bookmarks scatter by repo /
    -- launch dir and get swapped out on any global :cd. We always want ONE
    -- global store: marks persist everywhere, survive cwd changes, and stay put
    -- regardless of whether a file lives in a git repo. (fzf/telescope are
    -- already dir-scoped; haunt is the cross-everything layer.)
    project.get_info = function()
      return { root = nil, branch = nil, project_id = "haunt-global" }
    end
  end
end

map('n', '<leader>hm', function() require('haunt.api').toggle_annotation() end,
{ desc = "Toggle bookmark annotation" })

-- Navigate bookmarks
map('n', '<leader>hn', function() require('haunt.api').next() end,
{ desc = "Next bookmark" })
map('n', '<leader>hp', function() require('haunt.api').prev() end,
{ desc = "Previous bookmark" })

-- Annotate bookmark
map('n', '<leader>ha', function() require('haunt.api').annotate() end,
{ desc = "Annotate bookmark" })

-- Delete bookmark
map('n', '<leader>hd', function() require('haunt.api').delete() end,
{ desc = "Delete bookmark" })

-- Clear bookmarks
map('n', '<leader>hc', function() require('haunt.api').clear() end,
{ desc = "Clear bookmarks in file" })
map('n', '<leader>hC', function() require('haunt.api').clear_all() end,
{ desc = "Clear all bookmarks" })

-- List bookmarks
map('n', '<leader>hl', function() require('haunt.picker').show() end,
{ desc = "List bookmarks" })

-- =============================================================================
-- Checkmate
-- =============================================================================
require("checkmate").setup({
  files = { "/home/vectors/todo.md", "todo.md", "TODO.md" },
  -- Metadata tags. The built-in @priority/@started/@done stay as-is (keys
  -- <leader>Tp/Ts/Td); this block only ADDS @due. Naming an existing tag here
  -- would REPLACE it wholesale (no field merge), so we leave those alone.
  metadata = {
    -- @due(YYYY-MM-DD) — goes red+bold once the date is past
    due = {
      style = function(context)
        local y, m, d = tostring(context.value):match("(%d+)-(%d+)-(%d+)")
        if y then
          local due_at = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 23, min = 59 })
          if due_at < os.time() then
            return { fg = "#ff5555", bold = true } -- overdue
          end
        end
        return { fg = "#f1fa8c" } -- upcoming
      end,
      get_value = function()
        return tostring(os.date("%Y-%m-%d")) -- defaults to today; edit to your deadline
      end,
      key = "<leader>Tu",
      sort_order = 15,           -- sits between @priority (10) and @started (20)
      jump_to_on_insert = "value",
      select_on_insert = true,   -- drops cursor onto the date so you can type it
    },
  },
  keys = {
    ["<leader>bb"] = {
      rhs = "<cmd>Checkmate toggle<CR>",
      desc = "Toggle todo item",
      modes = { "n", "v" },
    },
    ["<leader>bc"] = {
      rhs = "<cmd>Checkmate check<CR>",
      desc = "Set todo item as checked (done)",
      modes = { "n", "v" },
    },
    ["<leader>bu"] = {
      rhs = "<cmd>Checkmate uncheck<CR>",
      desc = "Set todo item as unchecked (not done)",
      modes = { "n", "v" },
    },
    ["<leader>b="] = {
      rhs = "<cmd>Checkmate cycle_next<CR>",
      desc = "Cycle todo item(s) to the next state",
      modes = { "n", "v" },
    },
    ["<leader>b-"] = {
      rhs = "<cmd>Checkmate cycle_previous<CR>",
      desc = "Cycle todo item(s) to the previous state",
      modes = { "n", "v" },
    },
    ["<leader>bn"] = {
      rhs = "<cmd>Checkmate create<CR>",
      desc = "Create todo item",
      modes = { "n", "v" },
    },
    ["<leader>br"] = {
      rhs = "<cmd>Checkmate remove<CR>",
      desc = "Remove todo marker (convert to text)",
      modes = { "n", "v" },
    },
    ["<leader>bR"] = {
      rhs = "<cmd>Checkmate remove_all_metadata<CR>",
      desc = "Remove all metadata from a todo item",
      modes = { "n", "v" },
    },
    ["<leader>ba"] = {
      rhs = "<cmd>Checkmate archive<CR>",
      desc = "Archive checked/completed todo items (move to bottom section)",
      modes = { "n" },
    },
    ["<leader>bF"] = {
      rhs = "<cmd>Checkmate select_todo<CR>",
      desc = "Open a picker to select a todo from the current buffer",
      modes = { "n" },
    },
    ["<leader>bv"] = {
      rhs = "<cmd>Checkmate metadata select_value<CR>",
      desc = "Update the value of a metadata tag under the cursor",
      modes = { "n" },
    },
    ["<leader>b]"] = {
      rhs = "<cmd>Checkmate metadata jump_next<CR>",
      desc = "Move cursor to next metadata tag",
      modes = { "n" },
    },
    ["<leader>b["] = {
      rhs = "<cmd>Checkmate metadata jump_previous<CR>",
      desc = "Move cursor to previous metadata tag",
      modes = { "n" },
    },
  }
})

map("n", "<leader>bw", function() vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.expand("/home/vectors/todo.md"))) end, { desc = "open global tasks" })
-- =============================================================================

-- =============================================================================
-- zk — zettelkasten notes (notebook at ~/notes, set via ZK_NOTEBOOK_DIR)
-- =============================================================================
require("zk").setup({
  picker = "snacks_picker",          -- reuse snacks.nvim; no new picker dependency
  lsp = {
    config = { cmd = { "zk", "lsp" }, name = "zk" },
    auto_attach = { enabled = true }, -- link completion etc., only active inside a notebook
  },
})

local zk = require("zk")
local zkc = require("zk.commands")

map("n", "<leader>zn", function() zk.new({ title = vim.fn.input("Title: ") }) end,
  { desc = "zk: new note" })
map("n", "<leader>zo", function() zkc.get("ZkNotes")({ sort = { "modified" } }) end,
  { desc = "zk: open / list notes" })
map("n", "<leader>zf", function() zkc.get("ZkNotes")({ sort = { "modified" }, match = { vim.fn.input("Search: ") } }) end,
  { desc = "zk: search notes (full-text)" })
map("n", "<leader>zt", function() zkc.get("ZkTags")() end,
  { desc = "zk: browse tags" })
map("n", "<leader>zb", function() zkc.get("ZkBacklinks")() end,
  { desc = "zk: backlinks for this note" })
map("n", "<leader>zl", function() zkc.get("ZkInsertLink")() end,
  { desc = "zk: insert link to a note" })
map("v", "<leader>zn", ":'<,'>ZkNewFromTitleSelection<CR>",
  { desc = "zk: new note from selection" })
-- =============================================================================
-- Treesitter (parsers + queries; built-in highlight)
-- =============================================================================
local wanted_parsers = {
  "bash", "c", "cpp", "css", "dockerfile", "go", "gomod", "html", "javascript",
  "json", "lua", "markdown", "markdown_inline", "python", "query",
  "tsx", "typescript", "vim", "vimdoc", "yaml",
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

local ts_ok, ts = pcall(require, "nvim-treesitter")
if ts_ok and ts.install then
  vim.api.nvim_create_user_command("TSInstall", function(opts) ts.install(opts.fargs) end,
    { nargs = "+", desc = "Install treesitter parser(s)" })
  vim.api.nvim_create_user_command("TSInstallAll", function() ts.install(wanted_parsers) end,
    { desc = "Install all wanted parsers" })
end

-- =============================================================================
-- Completion (blink.cmp) — replaces nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path + lspkind
-- =============================================================================
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    -- Match the C-j / C-k navigation feel from your old config
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<CR>"]  = { "accept", "fallback" },
    ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    accept = { auto_brackets = { enabled = true } },
    menu = { border = "rounded" },
  },
  signature = { enabled = true },
})

-- =============================================================================
-- LSP (native, 0.11+)
-- =============================================================================
local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    on_attach(client, buf)

    local o = { buffer = buf }
    map("n", "gd",         vim.lsp.buf.definition,     o)
    map("n", "gr",         vim.lsp.buf.references,     o)
    map("n", "K",          vim.lsp.buf.hover,          o)
    map("n", "<leader>rn", vim.lsp.buf.rename,         o)
    map("n", "<leader>ca", vim.lsp.buf.code_action,    o)
    map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, o)
  end,
})

map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count =  1, float = true }) end, { desc = "Next diagnostic" })

vim.lsp.config("clangd",   { capabilities = capabilities, cmd = { "clangd", "--offset-encoding=utf-16" }, filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" } })
vim.lsp.config("lua_ls",   { capabilities = capabilities, settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } }, workspace = { checkThirdParty = false } } } })
vim.lsp.config("sourcekit",{ capabilities = capabilities, cmd = { "sourcekit-lsp" }, filetypes = { "swift", "objective-c", "objective-cpp" }, root_markers = { "Package.swift", ".git", ".sourcekit-lsp" } })
vim.lsp.config("ts_ls",    { capabilities = capabilities })
vim.lsp.config("pyright",  { capabilities = capabilities })
vim.lsp.config("gopls",    { capabilities = capabilities })
vim.lsp.config("texlab",   { capabilities = capabilities, cmd = { "texlab" }, filetypes = { "tex", "plaintex", "bib" }, root_markers = { ".git", ".latexmkrc", "Makefile", ".texlabroot" } })

vim.lsp.enable({ "clangd", "lua_ls", "sourcekit", "ts_ls", "pyright", "gopls", "texlab" })


-- =============================================================================
-- snacks.nvim — picker (replaces telescope), terminal (replaces floaterm),
-- ui.input/select (replaces dressing), dashboard, gitbrowse, zen, scratch
-- =============================================================================
local function pad_dashboard_header(header)
  local lines = vim.split(header, "\n", { plain = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  for i, line in ipairs(lines) do
    lines[i] = line .. (" "):rep(width - vim.fn.strdisplaywidth(line))
  end
  return table.concat(lines, "\n")
end

local dashboard_header = pad_dashboard_header([[
                                              s                
  x=~                                        :8                
 88x.   .e.   .e.                           .88                
'8888X.x888:.x888       .u         .u      :888ooo       u     
 `8888  888X '888k   ud8888.    ud8888.  -*8888888    us888u.  
  X888  888X  888X :888'8888. :888'8888.   8888    .@88 "8888" 
  X888  888X  888X d888 '88%" d888 '88%"   8888    9888  9888  
  X888  888X  888X 8888.+"    8888.+"      8888    9888  9888  
 .X888  888X. 888~ 8888L      8888L       .8888Lu= 9888  9888  
 `%88%``"*888Y"    '8888c. .+ '8888c. .+  ^%888*   9888  9888  
   `~     `"        "88888%    "88888%      'Y"    "888*""888" 
                      "YP'       "YP'               ^Y"   ^Y'  ]])
                                                               
                                                               
                                                               

require("snacks").setup({
  bigfile     = { enabled = true },
  bufdelete   = { enabled = true },
  gitbrowse   = { enabled = true },
  input       = { enabled = true },        -- replaces dressing input
  picker      = { enabled = true },        -- replaces telescope
  quickfile   = { enabled = true },
  scratch     = { enabled = true },
  words       = { enabled = true },
  zen         = { enabled = true },
  dashboard = {
    width    = 48,
    pane_gap = 32,
    preset = {
      header = dashboard_header,
      keys = {
        { icon = " ",  key = "e", desc = "New File",       action = ":ene | startinsert" },
        { icon = " ",  key = "o", desc = "File Explorer",  action = ":Oil --float" },
        { icon = "󰱼 ", key = "f", desc = "Find File",      action = function() Snacks.picker.files() end },
        { icon = " ",  key = "g", desc = "Find Word",      action = function() Snacks.picker.grep() end },
        { icon = " ",  key = "q", desc = "Quit",           action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1, pane = 1 },
      { section = "recent_files", icon = " ", title = "Recent Files", padding = 1, limit = 5 },
    },
  },
})

-- Picker keymaps (telescope replacement) — <leader>ff and <leader>fr KEPT IDENTICAL
map("n", "<leader>ff", function() Snacks.picker.files() end,        { desc = "Find files" })
map("n", "<leader>fr", function() Snacks.picker.recent() end,       { desc = "Recent files" })
map("n", "<leader>fs", function() Snacks.picker.grep() end,         { desc = "Live grep" })
map("n", "<leader>fc", function() Snacks.picker.grep_word() end,    { desc = "Grep word under cursor" })
map("n", "<leader>ft", function() Snacks.picker.lsp_symbols() end,  { desc = "Document symbols" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end,      { desc = "Buffers" })
map("n", "<leader>fh", function() Snacks.picker.help() end,         { desc = "Help" })
map("n", "<leader>fk", function() Snacks.picker.keymaps() end,      { desc = "Keymaps" })

-- Floating terminal (single persistent buffer, toggleable)
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
  local width  = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines   * 0.8)
  local col    = math.floor((vim.o.columns - width)  / 2)
  local row    = math.floor((vim.o.lines   - height) / 2)
  floaterm.win = vim.api.nvim_open_win(floaterm.buf, true, {
    relative = "editor",
    width = width, height = height, col = col, row = row,
    style = "minimal", border = "rounded",
  })
  if vim.bo[floaterm.buf].buftype ~= "terminal" then vim.cmd("terminal") end
  vim.cmd("startinsert")
end
map("n", "<leader>tt", function() floaterm_open(false) end, { desc = "Toggle terminal" })
map("n", "<leader>tm", function() floaterm_open(true)  end, { desc = "New terminal" })
map("t", "<C-q>",      function() floaterm_open(false) end, { desc = "Close terminal" })

-- Other snacks
map("n", "<leader>zz", function() Snacks.zen() end,                 { desc = "Zen mode" })
map("n", "<leader>bd", function() Snacks.bufdelete() end,           { desc = "Delete buffer" })
map("n", "<leader>bs", function() Snacks.scratch() end,             { desc = "Scratch buffer" })
map("n", "<leader>go", function() Snacks.gitbrowse() end,           { desc = "Open in GitHub" })

-- =============================================================================
-- VimTeX (LaTeX)
-- =============================================================================
vim.g.vimtex_view_method            = "zathura"
vim.g.vimtex_compiler_method        = "latexmk"
vim.g.vimtex_compiler_start_on_open = 1
vim.g.vimtex_compiler_latexmk = {
  continuous = 1,
  build_dir  = "build",
  aux_dir    = "build",
  out_dir    = "build",
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
vim.g.vimtex_quickfix_mode         = 0
vim.g.vimtex_complete_close_braces = 1
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = { "*.tex" },
  callback = function() vim.cmd("silent! update") end,
})
map("n", "<leader>lc", "<cmd>VimtexCompile<CR>", { desc = "VimTeX compile" })
