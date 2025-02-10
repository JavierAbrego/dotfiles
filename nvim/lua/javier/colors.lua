function SetTransparentBackground()
	-- Main UI Elements
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" }) -- Non-focused buffers
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" }) -- Floating windows border
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" }) -- Line number signs

	-- Telescope UI Elements
	vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })    -- Telescope menu
	vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })    -- Border around telescope
	vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" }) -- Input area
	vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })

	-- Status line & Tabline transparency
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
	--vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" }) -- Inactive status line
	vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
	vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none" })

	-- Popup menus
--	vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" }) -- Completion menu
--	vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none" }) -- Selected item in completion menu
	--vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "none" })
	--vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "none" })

	-- Others
	vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" }) -- Window separators
end

function SetTransparentBackgroundColorSchema(color)
	color = color or "gruvbox"
	vim.cmd.colorscheme(color)
	SetTransparentBackground()
end

SetTransparentBackgroundColorSchema('tokyonight-night')
