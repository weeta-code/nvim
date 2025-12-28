vim.g.copilot_no_tab_map = true

-- Accept (NO expr, NO functions)
vim.keymap.set('i', '<C-h>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})

-- Cycle
vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")

-- Dismiss
vim.keymap.set("i", "<C-l>", "<Plug>(copilot-dismiss)")

return {
  "github/copilot.vim",
  cmd = "Copilot",
  event = "InsertEnter",
}
