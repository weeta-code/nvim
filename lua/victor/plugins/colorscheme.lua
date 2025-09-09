return {
  "rebelot/kanagawa.nvim",
  priority=1000, 
  config = function()

    require("kanagawa").setup({
      compile = true,
      undercurl = true,
      commentStyle = { italic = false},
      functionStyle = { italic = false},
      keywordStyle = {italic = false},
      statementStyle = {bold = true},
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      colors = {
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors)
        return {}
      end,
      theme = "dragon",
      background = {
        dark = "dragon",
        light = "lotus"
      },
    })

    vim.cmd("colorscheme kanagawa")
  end 
}
