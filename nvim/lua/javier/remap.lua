vim.g.mapleader = ","
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<leader>wrk", SwitchWorkspaceDropdown)

-- Function to execute a command synchronously
local function execute_command(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return result
end

local function executeCurrentFileWithCommand(cmd)
		vim.cmd(':sp')
		local command = table.concat({":ter ", cmd," \"",vim.fn.expand("%"), '"'}, "")		
		vim.cmd(command)
end
-- Key mapping
vim.keymap.set("n", "<C-Enter>", function()
  local file_extension = vim.fn.expand("%:e")

  if file_extension == "c" then
			executeCurrentFileWithCommand('gcc')
	elseif file_extension == "java" then
			executeCurrentFileWithCommand('java')
	elseif file_extension == "py" then
			executeCurrentFileWithCommand('python3')
	elseif file_extension == "js" then
			executeCurrentFileWithCommand('node')
	elseif file_extension == "ts" then
			executeCurrentFileWithCommand('ts-node')
  else
    print("File extension not supported for execution.")
  end
end, { silent = true })

