
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeDirArrowExpandable = '+'
vim.g.NERDTreeDirArrowCollapsible = '-'
vim.keymap.set("n", "<leader>n", vim.cmd.NERDTreeFocus)
vim.keymap.set("n", "<C-n>", vim.cmd.NERDTree)
vim.keymap.set("n", "<C-t>", vim.cmd.NERDTreeToggle)
vim.keymap.set("n", "<C-f>", vim.cmd.NERDTreeFind)

