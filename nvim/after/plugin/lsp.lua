---
-- LSP setup
---

-- Reserve a space in the gutter
-- This will avoid an annoying layout shift in the screen
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lspconfig_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local opts = { buffer = event.buf, remap = false }

		vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
		-- Displays hover information about the symbol under the cursor in a floating window.
		-- See :help vim.lsp.buf.hover().

		vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
		vim.keymap.set("n", "gvd", function()
			vim.cmd("vsplit") -- This command opens a new vertical split window
			vim.lsp.buf.definition() -- This function jumps to the definition
		end, opts)
		-- Jumps to the definition of the symbol under the cursor.
		-- See :help vim.lsp.buf.definition().

		vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
		-- Jumps to the declaration of the symbol under the cursor.
		-- Some servers don't implement this feature.
		-- See :help vim.lsp.buf.declaration().

		vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
		-- Lists all the implementations for the symbol under the cursor in the quickfix window.
		-- See :help vim.lsp.buf.implementation().

		vim.keymap.set("n", "go", function() vim.lsp.buf.type_definition() end, opts)
		-- Jumps to the definition of the type of the symbol under the cursor.
		-- See :help vim.lsp.buf.type_definition().

		vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
		-- Lists all the references to the symbol under the cursor in the quickfix window.
		-- See :help vim.lsp.buf.references().

		vim.keymap.set("n", "gs", function() vim.lsp.buf.signature_help() end, opts)
		vim.keymap.set("i", "<C-Space>", function() vim.lsp.buf.signature_help() end, opts)
		-- Displays signature information about the symbol under the cursor in a floating window.
		-- See :help vim.lsp.buf.signature_help().
		-- If a mapping already exists for this key, this function is not bound.

		vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
		-- Renames all references to the symbol under the cursor.
		-- See :help vim.lsp.buf.rename().

		vim.keymap.set("n", "<F3>", function() vim.lsp.buf.format() end, opts)
		vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, opts)
		-- Format code in the current buffer.
		-- See :help vim.lsp.buf.format().

		vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
		-- Selects a code action available at the current cursor position.
		-- See :help vim.lsp.buf.code_action().

		vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, opts)
		-- Show diagnostics in a floating window.
		-- See :help vim.diagnostic.open_float().

		vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
		-- Move to the previous diagnostic in the current buffer.
		-- See :help vim.diagnostic.goto_prev().

		vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
		-- Move to the next diagnostic.
		-- See :help vim.diagnostic.goto_next().
		vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	end,
})

require('mason').setup({})
require('mason-lspconfig').setup({
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	}
})

---
-- Autocompletion config
---
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'render-markdown' },
	},
	mapping = cmp.mapping.preset.insert({
		-- `Enter` key to confirm completion
		['<CR>'] = cmp.mapping.confirm({ select = false }),

		['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		['<C-y>'] = cmp.mapping.confirm({ select = true }),
		-- Ctrl+Space to trigger completion menu
		--['<C-Space>'] = cmp.mapping.complete(),

		-- Scroll up and down in the completion documentation
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),
	}),
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	completion = {
		completeopt = 'menu,menuone,noinsert'
	}
})


vim.diagnostic.config({
	virtual_text = true
})

-- https://github.com/OlegGulevskyy/better-ts-errors.nvim/tree/main
-- better ts errors
require("better-ts-errors").setup({
	keymaps = {
		toggle = '<leader>dd',    -- Toggling keymap
		go_to_definition = '<leader>dx' -- Go to problematic type from popup window
	}
})
