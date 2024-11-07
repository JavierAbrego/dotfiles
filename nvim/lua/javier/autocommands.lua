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
