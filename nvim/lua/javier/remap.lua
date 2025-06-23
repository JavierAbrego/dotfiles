vim.keymap.set('n', '^', ':b#<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<leader>wrk", SwitchWorkspaceDropdown)
-- Create a custom mapping for Ctrl-c to behave like Esc but keep the cursor in place
vim.api.nvim_set_keymap('i', '<C-c>', '<Esc>`^', { noremap = true, silent = true })
-- save all
vim.keymap.set('n', '<leader>w', ':wa<CR>', opts)
-- leetcode
vim.keymap.set('n', '<leader>lr', ':Leet run<CR>')
vim.keymap.set('n', '<leader>lc', ':Leet console<CR>')
vim.keymap.set('n', '<leader>ls', ':Leet submit<CR>')
vim.keymap.set('n', '<leader>lm', ':Leet menu<CR>')
vim.keymap.set('n', '<leader>lo', ':Leet open<CR>')

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
	elseif file_extension == "cpp" then
			executeCurrentFileWithCommand('g++ -std=c++14')
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


vim.api.nvim_create_user_command('ReloadConfig', function()
  dofile(vim.env.MYVIMRC)
end, {})
--vim.keymap.set('n', '<C-m>', ':RenderMarkdown toggle<CR>')
