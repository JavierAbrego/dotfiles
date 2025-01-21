-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)


vim.g.mapleader = ","
local plugins = {
	{
		'vhyrro/luarocks.nvim',
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { 'magick' },
		},
	},
	{
		'nvim-telescope/telescope.nvim',
		version = '0.1.4',
		-- or                            , branch = '0.1.x',
		dependencies = { { 'nvim-lua/plenary.nvim' } }
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = function()
			local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
			ts_update()
		end
	},
	-- LSP Support
	{ 'neovim/nvim-lspconfig' },
	{
		'williamboman/mason.nvim',
		build = function()
			pcall(vim.cmd, 'MasonUpdate')
		end,
	},
	{ 'williamboman/mason-lspconfig.nvim' },

	-- Autocompletion
	{ 'hrsh7th/nvim-cmp' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/cmp-path' },
	{ 'saadparwaiz1/cmp_luasnip' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-nvim-lua' },

	-- Snippets
	{ 'L3MON4D3/LuaSnip' },
	{ 'rafamadriz/friendly-snippets' },

	-- navigation
	'preservim/nerdtree',
	-- colorschemas
	'folke/tokyonight.nvim',
	'shaunsingh/nord.nvim',
	{ "ellisonleao/gruvbox.nvim" },
	"rebelot/kanagawa.nvim",
	'projekt0n/github-nvim-theme',
	-- see commiter in line
	'apzelos/blamer.nvim',
	-- better ts messages
	{
		"OlegGulevskyy/better-ts-errors.nvim",
		dependencies = {
			{ 'MunifTanjim/nui.nvim' }
		}
	},

	-- Lightning fast left-right movement in Vim
	'unblevable/quick-scope',

	-- leetcode directly on nvim
	{
		'kawre/leetcode.nvim',
		build = ':TSUpdate html', -- if you have `nvim-treesitter` installed
		dependencies = {
			'nvim-telescope/telescope.nvim',
			-- 'ibhagwan/fzf-lua', -- Uncomment if you decide to  it
			'nvim-lua/plenary.nvim',
			'MunifTanjim/nui.nvim',
		}
	},
	-- render markdown
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'echasnovski/mini.nvim', lazy = true }, -- if you  the mini.nvim suite
		{ 'nvim-treesitter' },
		-- dependencies = { 'echasnovski/mini.icons', opt = true }, -- if you  standalone mini plugins
		-- dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
		config = function()
			require('render-markdown').setup({})
		end,
	},
}
require("lazy").setup(plugins, opts)
