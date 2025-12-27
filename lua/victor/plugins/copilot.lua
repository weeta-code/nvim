vim.g.copilot_no_tab_map = true

vim.keymap.set("i", "<C-h>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

vim.keymap.set("i", "<C-j>", 'copilot#Previous()', { silent = true, expr = true })
vim.keymap.set("i", "<C-k>", 'copilot#Next()', { silent = true, expr = true })
vim.keymap.set("i", "<C-l>", 'copilot#Dismiss()', { silent = true, expr = true })

return {
  "github/copilot.vim",
  cmd = "Copilot",
  event = "InsertEnter",
}
