vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs n stuff
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true --copy indent from current line when starting new ones

opt.wrap = false

-- searchs ettings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- to include mixed casing in the search

opt.cursorline = true

-- background
opt.background = "dark" -- default dark mode for colorschemes
opt.signcolumn = "yes" -- showing sign column so text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allowing backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register!

--split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window ot the bottom


