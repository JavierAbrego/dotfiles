vim.cmd([[
augroup FiletypeAutoCommands
  autocmd!
  autocmd BufReadPost *.doc,*.docx,*.rtf,*.odp,*.odt,*.pdf,*.pptx,*.ppt,*.xlsx,*.xls,*.msg silent execute "%!tika -t" shellescape(expand("%"), 1)
augroup END
]])

vim.api.nvim_create_augroup("qs_colors", { clear = true })

vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true })
vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline= true})
vim.api.nvim_create_autocmd("ColorScheme", {
  group = "qs_colors",
  callback = function()
    vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true })
    vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline= true})
  end,
})


-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   group = vim.api.nvim_create_augroup("ts_imports", { clear = true }),
--   pattern = { "*.tsx,*.ts" },
--   callback = function()
--     vim.lsp.buf.code_action({
--       apply = true,
--       context = {
--         only = { "source.organizeImports.ts" },
--         diagnostics = {},
--       },
--     })
--   end,
-- })
--
--source.fixAll.ts - despite the name, fixes a couple of specific issues: unreachable code, await in non-async functions, incorrectly implemented interface
-- source.removeUnused.ts - removes declared but unused variables
-- source.addMissingImports.ts - adds imports for used but not imported symbols
-- source.removeUnusedImports.ts - removes unused imports
-- source.sortImports.ts - sorts imports
-- source.organizeImports.ts - organizes and removes unused imports
