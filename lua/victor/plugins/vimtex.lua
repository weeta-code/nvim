return {
  "lervag/vimtex",
  ft = { "tex", "plaintex", "latex" },
  
  init = function()
    vim.g.tex_flavor = "latex"

    -- Viewer stuf
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1

    -- Compiling
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

  -- autosave
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      pattern = { "*.tex" },
      callback = function()
        vim.cmd("silent! update")
      end,
    })
  end,
} 
