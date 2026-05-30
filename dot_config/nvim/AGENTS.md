# Neovim Configuration Agent Guidelines

This document contains guidelines for agentic coding agents working on this Neovim configuration repository.

## Repository Structure

This is a personal Neovim configuration using the Lua-based configuration system. The main entry point is `init.lua` which requires the `niel` module.

```
.
├── init.lua                 # Main entry point
├── lua/
│   └── niel/
│       ├── init.lua         # Module entry point
│       ├── set.lua          # Basic options/settings
│       ├── remap.lua        # Key mappings
│       ├── micropython.lua  # MicroPython-specific config
│       ├── config/
│       │   └── lazy.lua     # Lazy.nvim bootstrap and setup
│       └── plugins/
│           ├── init.lua     # Base plugin dependencies
│           ├── lsp.lua      # LSP configuration
│           ├── treesitter.lua # TreeSitter configuration
│           ├── telescope.lua # Telescope file finder
│           ├── harpoon.lua  # Harpoon navigation
│           └── ...           # Other plugins
```

## Build/Lint/Test Commands

This is a Neovim configuration repository - there are no traditional build/test commands. However, agents should:

1. **Validate Lua syntax**: Use `luac -p` on any modified Lua files
   ```bash
   luac -p lua/niel/example.lua
   ```

2. **Test configuration**: Restart Neovim to test changes
   ```bash
   nvim --headless -c "lua require('niel')" -c "qa"
   ```

3. **Check plugin installation**: Lazy.nvim will handle plugin management automatically

4. **LSP diagnostics**: The configuration includes lua_ls for real-time linting

## Code Style Guidelines

### General Principles
- Use 4 spaces for indentation (configured in `set.lua`)
- Keep lines reasonably long (no strict limit, but prioritize readability)
- Use local variables whenever possible
- Follow Lua conventions for variable naming

### Import/Module Patterns
```lua
-- Preferred: require statements at top of file
local lazy = require("lazy")
local lspconfig = require("lspconfig")

-- For Neovim API, use vim.* directly
vim.opt.number = true
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
```

### Configuration Style
```lua
-- Plugin specifications return tables
return {
    "plugin-author/plugin-name",
    dependencies = {
        "dependency/plugin"
    },
    config = function()
        -- Configuration logic here
    end,
}
```

### Neovim API Usage
```lua
-- Use vim.opt for list-like options
vim.opt.number = true
vim.opt.tabstop = 4

-- Use vim.o for single-value options  
vim.o.scrolloff = 10
vim.o.expandtab = false

-- Use vim.g for global variables
vim.g.mapleader = " "
```

### Key Mapping Patterns
```lua
-- Use vim.keymap.set for new mappings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- For complex mappings, include description
vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
    vim.cmd("normal! zz")
end, { buffer = bufnr, desc = "Go to definition" })
```

### Autocmd Patterns
```lua
-- Use nvim_create_augroup for grouping
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        -- Handler logic
    end,
})
```

### Error Handling
```lua
-- Use pcall for safe operations
local ok, result = pcall(vim.loop.fs_stat, filepath)
if ok and result then
    -- Process result
end

-- Use assert for expected conditions
local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
```

### Plugin Configuration
- Keep plugin configurations modular - one file per plugin category
- Use lazy loading when possible
- Configure dependencies explicitly
- Follow each plugin's documented configuration patterns

### File Organization
- `set.lua`: Basic Neovim options and settings
- `remap.lua`: Global key mappings not tied to specific plugins  
- `plugins/`: Plugin-specific configurations
- `config/`: Core configuration like lazy.nvim setup

### Special Considerations
- This config includes MicroPython-specific functionality in `micropython.lua`
- LSP formatting is disabled for C/C++ files (line 35 in lsp.lua)
- TreeSitter includes custom templ parser configuration
- Uses modern Neovim features (vim.keymap.set, vim.api.nvim_create_autocmd)

### Common Patterns
```lua
-- Plugin spec with dependencies
return {
    "main/plugin",
    dependencies = {
        "dep/plugin1",
        {"dep/plugin2", config = true},
    },
    config = function()
        require("plugin").setup({...})
    end,
}

-- Conditional configuration
if ft == "c" or ft == "cpp" then 
    return 
end
```

## Testing Configuration Changes

When making changes:
1. Check Lua syntax with `luac -p`
2. Test with `nvim --headless` for basic validation
3. Restart Neovim to test interactive functionality
4. Verify LSP and TreeSitter are working correctly
5. Check that key mappings function as expected

## Performance Considerations
- Use `ft = "lua"` for lazy loading language-specific plugins
- Disable TreeSitter highlighting for large files (>100KB)
- Use `change_detection = { notify = false }` in lazy.nvim setup
- Consider auto-install vs manual install choices carefully