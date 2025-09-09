return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_reference<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["emmet_ls"] = function()
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })
      end,
      ["lua_ls"] = function()
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["pyright"] = function()
        local pyright_opts = {
          single_file_support = true,
          settings = {
            pyright = {
              disableLanguageServices = false,
              disableOrganizeImports = false
            },
            python = {
              analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace", -- openFilesOnly, workspace
                typeCheckingMode = "basic", -- off, basic, strict
                useLibraryCodeForTypes = true
              }
            }
          },
        }
        lspconfig["pyright"].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, pyright_opts))
      end,
      -- C/C++ configuration with specified arguments
      ["clangd"] = function()
        local clangd_opts = {
          -- clangd settings are typically passed as command-line arguments to the server.
          -- We define a `cmd` table to explicitly pass these arguments.
          cmd = {
            "clangd",
            "--background-index",          -- Enable background indexing
            "--completion-style=detailed", -- Detailed completion results
            "--suggest-missing-includes",  -- Suggest missing includes
            -- Add other clangd arguments here if needed
            -- "--clang-tidy", -- Enable clang-tidy checks (requires clang-tidy to be in your PATH)
            -- "--header-insertion-decorators", -- Show where includes would be added
            -- "--query-driver=/usr/bin/g++", -- Example: Specify GCC driver path if clangd struggles to find headers
            -- "--compile-commands-dir=build", -- If you have a specific build directory for compile_commands.json
          },
          -- clangd can also have a 'settings' table for certain configurations,
          -- but many common ones are via `cmd` arguments.
          settings = {
            -- Fallback flags (used if no compile_commands.json is found)
            -- These are passed to clang via the LSP.
            clangd = {
              fallbackFlags = {
                "-std=c++17",
                "-Wall",
              },
            },
          },
          -- Define root markers for clangd
          root_dir = lspconfig.util.root_pattern(
            "compile_commands.json",
            "compile_flags.txt",
            ".git",
            "build.ninja"
          ),
        }
        lspconfig["clangd"].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, clangd_opts))
      end,
      -- Java configuration with dynamic workspace
      ["jdtls"] = function()
        -- Determine the project root dynamically
        -- This will search upwards for common Java project markers.
        local root_dir = lspconfig.util.root_pattern(
          "pom.xml",
          "build.gradle",
          "settings.gradle",
          ".git",
          "mvnw",
          "gradlew"
        )(vim.api.nvim_buf_get_name(0)) -- Pass current buffer name to start search

        -- Define the workspace directory relative to the Neovim cache path,
        -- using the project root folder name to make it unique per project.
        local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":t")
        local jdtls_workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

        local jdtls_opts = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx2G", -- Increased memory to 2GB, adjust as needed for larger projects
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/lib/plugins/org.eclipse.equinox.launcher_*.jar"),
            "-configuration", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/config_linux"), -- IMPORTANT: Adjust 'config_linux' for your OS (e.g., 'config_mac', 'config_win')
            "-data", jdtls_workspace_dir, -- Dynamic workspace directory
          },
          root_dir = root_dir, -- Explicitly set root_dir for lspconfig
          settings = {
            java = {
              signatureHelp = {
                enabled = true,
              },
              completion = {
                enabled = true,
                overwrite = true,
                guessMethodArgument = {
                  enabled = true,
                },
              },
              format = {
                enabled = true,
              },
              selectionRange = {
                enabled = true,
              },
              sources = {
                organizeImports = {
                  enabled = true,
                  starThreshold = 99,
                  staticStarThreshold = 99,
                },
              },
              references = {
                includeDecompiledSources = true,
              },
              progress = {
                enabled = true,
              },
              maven = {
                downloadSources = true,
              },
              errors = {
                -- You can add specific error settings here if needed,
                -- e.g., for specific compiler warnings or checks.
              },
            },
          },
        }
        lspconfig["jdtls"].setup(vim.tbl_deep_extend("force", { capabilities = capabilities }, jdtls_opts))
      end,
    })
  end,
}
