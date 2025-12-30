# Fix: module 'nvim-treesitter.configs' not found

This repository had an issue where Neovim raises:

```
module 'nvim-treesitter.configs' not found
```

This error means `require("nvim-treesitter.configs")` is executed before the nvim-treesitter plugin is loaded by Lazy.nvim. It is NOT a missing system Lua/Tree-sitter issue.

Root causes and how to fix them:

1. Manual require() of plugin spec files
   - Do NOT call e.g. `require("victor.plugins")` or import your `plugins` directory directly. Those files are Lazy.nvim plugin specs and must not be executed directly.
   - Fix: remove manual `require(...)` calls for plugin spec files. Let Lazy scan the plugin spec namespace.

2. Lazy.nvim not scanning the plugin directory
   - Ensure you initialize Lazy.nvim with the plugin namespace, e.g.:
```lua
require("lazy").setup("victor.plugins")
```

3. A stray `require("nvim-treesitter.configs")` exists outside a plugin spec
   - Move any direct calls to `nvim-treesitter.configs` inside the plugin spec's `config = function() ... end` or `opts`.

4. Plugin spec directory imported as Lua
   - Never `require("<your>.plugins")` if it imports plugin files. Let Lazy handle discovery.

5. Plugin never installed by Lazy
   - If the plugin does not appear in `:Lazy`, run `:Lazy sync` and ensure your specs are registered.

Minimal working example:

```lua
-- lazy.lua
require("lazy").setup("victor.plugins")

-- victor/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-treesitter.configs").setup({})
  end,
}
```

**No plugin specs should ever be imported manually.**

CI check
-------

A GitHub Action is included that scans the repo for problematic patterns (direct requires of `nvim-treesitter.configs` or requiring the plugins directory). If found, the check fails and points to this document.
