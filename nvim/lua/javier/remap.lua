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

-- Key mapping
vim.keymap.set("n", "<C-Enter>", function()
  local file_extension = vim.fn.expand("%:e")

  if file_extension == "c" then
    -- Compile C file using gcc
    execute_command("gcc " .. vim.fn.expand("%") .. " -o " .. vim.fn.expand("%:r"))
  elseif file_extension == "java" then
    -- Execute Java file using java command
    execute_command("java " .. vim.fn.expand("%:r"))
  elseif file_extension == "py" then
    -- Execute Python file using python3 command
    execute_command("python3 " .. vim.fn.expand("%"))
  elseif file_extension == "js" then
    -- Execute JavaScript file using node command
    execute_command("node " .. vim.fn.expand("%"))
  elseif file_extension == "ts" then
    -- Execute TypeScript file using ts-node command
    execute_command("ts-node " .. vim.fn.expand("%"))
  else
    -- File extension not supported
    print("File extension not supported for execution.")
  end
end, { silent = true })

