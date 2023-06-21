vim.cmd([[
augroup FiletypeAutoCommands
  autocmd!
  autocmd BufReadPost *.doc,*.docx,*.rtf,*.odp,*.odt,*.pdf,*.pptx,*.ppt,*.xlsx,*.xls,*.msg silent execute "%!tika -t" shellescape(expand("%"), 1)
augroup END
]])
