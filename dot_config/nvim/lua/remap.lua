vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.api.nvim_set_keymap("i", "<C-v>", "<C-r>+", { noremap = true, silent = true })
vim.keymap.set("x", "<C-/>", [[:s/^\s*\/\/\s\?//<CR>]], { noremap = true, silent = true }) 

