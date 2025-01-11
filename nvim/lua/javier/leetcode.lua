
require('leetcode').setup({
		-- General Options
		arg = "leetcode.nvim",
		lang = "ts",

		-- China-specific Options
		cn = { -- leetcode.cn
		enabled = false,
		translator = true,
		translate_problems = true,
},

-- Storage Configuration
storage = {
		home = vim.fn.stdpath("data") .. "/leetcode",
		cache = vim.fn.stdpath("cache") .. "/leetcode",
},

-- Plugin Options
plugins = {
		non_standalone = false,
},

-- Logging
logging = true,

-- Injector Configuration
injector = {},

-- Cache Settings
cache = {
		update_interval = 60 * 60 * 24 * 7, -- 7 days
},

-- Console Configuration
console = {
		open_on_runcode = true,
		dir = "row",
		size = {
				width = "90%",
				height = "75%",
		},
},

-- Result Window Configuration
result = {
		size = "60%",
},

-- Testcase Configuration
testcase = {
		virt_text = true,
		size = "40%",
},

-- Description Window Configuration
description = {
		position = "left",
		width = "40%",
		show_stats = true,
},

-- Picker Configuration
picker = { provider = nil },

-- Hooks
hooks = {
		["enter"] = {},
		["question_enter"] = {},
		["leave"] = {},
},

-- Keybindings
keys = {
		toggle = { "q" },
		confirm = { "<CR>" },
		reset_testcases = "r",
		use_testcase = "U",
		focus_testcases = "H",
		focus_result = "L",
},

-- Theme Configuration
theme = {},

-- Image Support
image_support = false,
						})
