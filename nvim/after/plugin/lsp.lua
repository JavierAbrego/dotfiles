local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'ts_ls',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  --["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	-- Displays hover information about the symbol under the cursor in a floating window.
	-- See :help vim.lsp.buf.hover().

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "gvd", function()
    vim.cmd("vsplit")  -- This command opens a new vertical split window
    vim.lsp.buf.definition()  -- This function jumps to the definition
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
end)

-- lsp.skip_server_setup({'jdtls'})

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

-- https://github.com/OlegGulevskyy/better-ts-errors.nvim/tree/main
-- better ts errors
require("better-ts-errors").setup({
    keymaps = {
      toggle = '<leader>dd', -- Toggling keymap
      go_to_definition = '<leader>dx' -- Go to problematic type from popup window
    }
})
