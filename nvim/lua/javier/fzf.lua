local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require "telescope.utils"

local readWorkSpacesFromFile = function()
		-- Open the file in read mode
		local fileName = os.getenv("HOME").."/.wrk-spaces"
		local file = io.open(fileName, "r")

		-- Check if the file was opened successfully
		if file then
				-- Create an empty array to store the lines
				local lines = {}

				-- Read each line of the file and append it to the array
				for line in file:lines() do
						table.insert(lines, line)
				end

				-- Close the file
				file:close()

				-- Now you can use the 'lines' array
				-- Print each line for demonstration
				for i, line in ipairs(lines) do
						print("Line", i, ":", line)
				end
				return lines
		else
				print("Failed to open the file.")
		end
end

local function switchWorkspaceMapping(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						vim.api.nvim_set_current_dir(selection[1])
						actions.close(prompt_bufnr)
						utils.notify("fzf.switch_workspace", {
								msg = string.format("Switched to a new project: %s", selection[1]),
								level = "INFO",
						})
				end
local switch_workspace = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "change_workspace",
    finder = finders.new_table {
      --results = { "red", "green", "blue" }
      results = readWorkSpacesFromFile()
    },
    sorter = conf.generic_sorter(opts),
		attach_mappings = function (_, map)
				actions.select_default:replace(switchWorkspaceMapping)
				map({ "i", "n"}, "<c-g>",  switchWorkspaceMapping	)
				return true
		end
  }):find()
end

function SwitchWorkspaceDropdown()
		switch_workspace(require("telescope.themes").get_dropdown{})
end
