local cmp = require('cmp')
cmp.setup({
    sources = cmp.config.sources({
        { name = 'render-markdown' },
    }),
})
--require('blink.cmp').setup({
--    sources = {
--        default = { 'lsp', 'path', 'snippets', 'buffer', 'markdown' },
--        providers = {
--            markdown = {
--                name = 'RenderMarkdown',
--                module = 'render-markdown.integ.blink',
--                fallbacks = { 'lsp' },
--            },
--        },
--    },
--})
vim.keymap.set('n', '<C-m>', ':RenderMarkdown toggle<CR>')
