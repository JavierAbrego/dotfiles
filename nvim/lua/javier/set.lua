--vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim_undo/undo"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = false

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50 -- avoids delay on lsps

vim.opt.colorcolumn = "80"
-- migrate config from vimrc
-- Use Lua compatibility mode
vim.opt.compatible = false
-- Use the OS clipboard by default
vim.opt.clipboard:append("unnamed")
vim.api.nvim_set_option("clipboard","unnamedplus")
-- Enhance command-line completion
vim.opt.wildmenu = true
-- Allow cursor keys in insert mode
-- vim.opt.esckeys = true
-- Allow backspace in insert mode
vim.opt.backspace:append("indent,eol,start")
-- Optimize for fast terminal connections
vim.opt.ttyfast = true
-- Add the g flag to search/replace by default
vim.opt.gdefault = true
-- Use UTF-8 without BOM
vim.opt.encoding = "utf-8"
vim.opt.bomb = false
-- Change mapleader
vim.g.mapleader = ","
-- Don’t add empty newlines at the end of files
vim.opt.binary = true
vim.opt.eol = false
-- Centralize backups, swapfiles, and undo history
vim.opt.backupdir = os.getenv("HOME") .. "/.vim_undo/backups"
vim.opt.directory = os.getenv("HOME") .. "/.vim_undo/swaps"
if vim.fn.exists("&undodir") == 1 then
  vim.opt.undodir = os.getenv("HOME") .. "/.vim_undo/undo"
end
-- Don’t create backups when editing files in certain directories
vim.opt.backupskip = "/tmp/*,/private/tmp/*"
-- Respect modeline in files
vim.opt.modeline = true
vim.opt.modelines = 4
-- Enable per-directory .vimrc files and disable unsafe commands in them
vim.opt.exrc = true
vim.opt.secure = true
-- Enable line numbers
vim.opt.number = true
-- Enable syntax highlighting
vim.cmd("syntax on")
-- Highlight current line
vim.opt.cursorline = true
-- Make tabs as wide as two spaces
vim.opt.tabstop = 2
-- Show “invisible” characters
vim.opt.list = true
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  eol = "¬",
  nbsp = "_",
}
-- Highlight searches
vim.opt.hlsearch = true
-- Ignore case of searches
vim.opt.ignorecase = true
-- Highlight dynamically as pattern is typed
vim.opt.incsearch = true
-- Always show status line
vim.opt.laststatus = 2
-- Enable mouse in all modes
vim.opt.mouse = "a"
-- Disable error bells
vim.opt.errorbells = false
-- Don’t reset cursor to start of line when moving around
vim.opt.startofline = false
-- Show the cursor position
vim.opt.ruler = true
-- Don’t show the intro message when starting Vim
vim.opt.shortmess:append("atI")
-- Show the current mode
vim.opt.showmode = true
-- Show the filename in the window titlebar
vim.opt.title = true
-- Show the (partial) command as it’s being typed
vim.opt.showcmd = true
-- Searching at the end of file doesn't go to the next result on the top
-- vim.opt.wrapscan = false
-- Enable auto indent
vim.opt.autoindent = true
