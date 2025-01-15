-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.4',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
   use {
	   'nvim-treesitter/nvim-treesitter',
	   run = function()
		   local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
		   ts_update()
	   end
   }
    use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v1.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {
			  'williamboman/mason.nvim',
			  run = function()
				  pcall(vim.cmd, 'MasonUpdate')
			  end,
		  },
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }
  use 'preservim/nerdtree'
	-- colorschemas
  use 'folke/tokyonight.nvim'
	use 'shaunsingh/nord.nvim'
	use { "ellisonleao/gruvbox.nvim" }
	use "rebelot/kanagawa.nvim"
	use 'projekt0n/github-nvim-theme'
	-- see commiter in line
	use 'apzelos/blamer.nvim'
	-- better ts messages
	use {"OlegGulevskyy/better-ts-errors.nvim",
		requires = {
				{'MunifTanjim/nui.nvim'}
		}
	}
  use 'unblevable/quick-scope'
	--
	-- leetcode directly on nvim
	use {
        'kawre/leetcode.nvim',
        run = ':TSUpdate html', -- if you have `nvim-treesitter` installed
        requires = {
            'nvim-telescope/telescope.nvim',
            -- 'ibhagwan/fzf-lua', -- Uncomment if you decide to use it
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
        }
		}
		-- render markdown
use({
    'MeanderingProgrammer/render-markdown.nvim',
    after = { 'nvim-treesitter' },
    requires = { 'echasnovski/mini.nvim', opt = true }, -- if you use the mini.nvim suite
    -- requires = { 'echasnovski/mini.icons', opt = true }, -- if you use standalone mini plugins
    -- requires = { 'nvim-tree/nvim-web-devicons', opt = true }, -- if you prefer nvim-web-devicons
    config = function()
        require('render-markdown').setup({})
    end,
})
end)
