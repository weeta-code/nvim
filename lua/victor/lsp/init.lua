local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end
})

vim.keymap.set("n", "[d", function()
  vim.diagnostic.goto_prev()
  vim.diagnostic.open_float(nil, { focus = false })
end, { buffer = bufnr })

vim.keymap.set("n", "]d", function()
  vim.diagnostic.goto_next()
  vim.diagnostic.open_float(nil, { focus = false })
end, { buffer = bufnr })

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" }},
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("tsserver", {
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  capabilities = capabilities,
})

vim.lsp.config("gopls", {
  capabilities = capabilities,
})

vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--offset-encoding=utf-16" },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("tsserver")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("clangd")
