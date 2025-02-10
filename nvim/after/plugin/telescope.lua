local telescope = require('telescope')
local builtin = require('telescope.builtin')
telescope.setup {
		pickers = {
				find_files = {
						hidden = true,
						file_ignore_patterns = { ".git/", "node_modules/" }
				},
				colorscheme = {
						enable_preview = true
				}
		}
}
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>fa', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})
vim.keymap.set('n', '<leader>cs', function()
    builtin.colorscheme({
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                require("telescope.actions").select_default(prompt_bufnr)
                vim.defer_fn(function()
                    SetTransparentBackground()
                end, 50)
            end)
            return true
        end
    })
end, {})
--git telescope
vim.keymap.set('n', '<leader>gc', builtin.git_commits, {})
vim.keymap.set('n', '<leader>gcc', builtin.git_bcommits, {})
vim.keymap.set('n', '<leader>gb', builtin.git_branches, {})
vim.keymap.set('n', '<leader>gs', builtin.git_status, {})

vim.keymap.set('n', '<leader>fr', builtin.resume, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({search = vim.fn.input("Grep > ")})
end)

vim.keymap.set('n', '<leader>mm', builtin.man_pages, {})
vim.keymap.set('n', '<leader>rr', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>dd', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>tt', builtin.lsp_type_definitions, {})
