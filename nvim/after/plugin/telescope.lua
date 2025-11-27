local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    -- Usa fd para buscar ficheros (mucho más rápido que find)
    find_command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' },

    file_ignore_patterns = { ".git/", "node_modules/", ".next/", "dist/", "target/" },

    sorting_strategy = "ascending",
    layout_strategy = "flex",
    path_display = { "absolute" },

    prompt_prefix = "  ",       -- ícono de búsqueda
    selection_caret = " ",
    entry_prefix = "  ",

    color_devicons = true,       -- ✅ mantener iconos
    set_env = { ["COLORTERM"] = "truecolor" },

    preview = { treesitter = true },  -- ✅ mantener previews con resaltado

    buffer_previewer_maker = function(filepath, bufnr, opts)
      local stat = vim.loop.fs_stat(filepath)
      if stat and stat.size > 500000 then
        -- no previsualiza ficheros de más de ~500KB
        return
      else
        require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
      end
    end,
  },

  pickers = {
    find_files = {
      hidden = true,
    },
    colorscheme = {
      enable_preview = true,
    },
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    cached = {
      num_results = 2000, -- cachea hasta 2000 resultados
      ttl_mins = 60,      -- expira en 1 hora
    },
  },
})

-- Cargar extensiones si están instaladas
pcall(telescope.load_extension, 'fzf')

-- ======================
-- =  MAPEOS PERSONALIZADOS  =
-- ======================

-- Buscar ficheros (cacheado si es posible)
-- Buscar ficheros Git (usa git_files si hay repo, sino find_files)
vim.keymap.set('n', '<leader>ff', function()
  local ok = pcall(builtin.git_files, { show_untracked = true })
  if not ok then
    builtin.find_files({ hidden = true })
  end
end, { desc = 'Buscar ficheros Git o todos si no es repo' })

-- Buscar todos los ficheros
vim.keymap.set('n', '<leader>fa', function()
  builtin.find_files({ hidden = true })
end, { desc = 'Buscar todos los ficheros' })

vim.keymap.set('n', '<leader>fg', function()
  require('telescope.builtin').live_grep({
    additional_args = function()
      return { "--glob", "!*.md" }  -- esta es la forma correcta
    end,
  })
end, { desc = "Live grep (sin markdown)" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})

-- Colorscheme con transparencia (manteniendo tu lógica)
vim.keymap.set('n', '<leader>cs', function()
  builtin.colorscheme({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        require("telescope.actions").select_default(prompt_bufnr)
        vim.defer_fn(function()
          SetTransparentBackground()
        end, 50)
      end)
      return true
    end
  })
end, {})

-- Git pickers
vim.keymap.set('n', '<leader>gc', builtin.git_commits, {})
vim.keymap.set('n', '<leader>gcc', builtin.git_bcommits, {})
vim.keymap.set('n', '<leader>gb', builtin.git_branches, {})
vim.keymap.set('n', '<leader>gs', builtin.git_status, {})

-- Utilidades
vim.keymap.set('n', '<leader>fr', builtin.resume, {})
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.keymap.set('n', '<leader>mm', builtin.man_pages, {})
vim.keymap.set('n', '<leader>rr', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>dd', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>tt', builtin.lsp_type_definitions, {})

----------------------------------------------------------
-- Highlights para cada tipo de función
----------------------------------------------------------
vim.api.nvim_set_hl(0, "TSExportFunction", { fg = "#7ef29c" })
vim.api.nvim_set_hl(0, "TSNamedFunction",  { fg = "#e6db74" })
vim.api.nvim_set_hl(0, "TSArrowFunction",  { fg = "#ff9da4" })
vim.api.nvim_set_hl(0, "TSMethod",         { fg = "#9dc6ff" })
vim.api.nvim_set_hl(0, "TSCallback",       { fg = "#d6aaff" })

----------------------------------------------------------
-- Helpers
----------------------------------------------------------
local ts = vim.treesitter
local tsq = vim.treesitter.query

local function get_node_text(node, bufnr)
  return ts.get_node_text(node, bufnr)
end

local function make_tree_sitter_function_list(bufnr)
  local lang = vim.bo[bufnr].filetype
  local parser = ts.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  --------------------------------------------------------
  -- Query oficial válida para tree-sitter-javascript/ts
  --------------------------------------------------------
  local query = tsq.parse(lang, [[
;; export function foo() {}
(export_statement
  (function_declaration
    name: (identifier) @export_name)
) @fn_export

    ;; function foo() {}
    (function_declaration
      name: (identifier) @named_name
    ) @fn_named

    ;; const foo = () => {}
    (variable_declarator
      name: (identifier) @arrow_name
      value: (arrow_function) @arrow_fn
    ) @fn_arrow

    ;; const foo = function() {}
    (variable_declarator
      name: (identifier) @func_expr_name
      value: (function_expression) @func_expr
    ) @fn_func_expr

    ;; callbacks: x => ...
    (arrow_function) @fn_arrow_callback

    ;; métodos de objetos o clases
    (method_definition
      name: (property_identifier) @method_name
    ) @fn_method
  ]])

  local functions = {}

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local cap = query.captures[id]
    local text = get_node_text(node, bufnr)
    local row, col = node:range()

    local label
    local hl

    if cap == "export_name" then
      hl = "TSExportFunction"
      label = "export function " .. text

    elseif cap == "named_name" then
      hl = "TSNamedFunction"
      label = "function " .. text

    elseif cap == "arrow_name" then
      hl = "TSArrowFunction"
      label = text .. " = () =>"

    elseif cap == "func_expr_name" then
      hl = "TSArrowFunction"
      label = text .. " = function"

    elseif cap == "fn_arrow_callback" then
      hl = "TSCallback"
      label = "callback => …" .. text

    elseif cap == "method_name" then
      hl = "TSMethod"
      label = "method " .. text
    end

    if label then
      table.insert(functions, {
        label = label,
        hl = hl,
        lnum = row,
        col = col,
      })
    end
  end

  return functions
end

----------------------------------------------------------
-- Picker Telescope
----------------------------------------------------------
local function telescope_functions_colored()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  local funcs = make_tree_sitter_function_list(bufnr)
  if #funcs == 0 then
    vim.notify("No functions found via Tree-sitter", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local entry_display = require("telescope.pickers.entry_display")

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 50 },
      { remaining = true },
    },
  })

  pickers
    .new({}, {
      prompt_title = "Funciones coloreadas (Tree-sitter OK)",
      finder = finders.new_table({
        results = funcs,
        entry_maker = function(item)
          return {
            value = item,
            ordinal = item.label,
            display = function()
              return displayer({
                { item.label, item.hl },
                { "l:" .. (item.lnum + 1), "Comment" },
              })
            end,
            lnum = item.lnum +1,
            col = item.col+1,
            filename = filepath,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.qflist_previewer({}),
    })
    :find()
end

----------------------------------------------------------
-- Keymap
----------------------------------------------------------
vim.keymap.set("n", "<leader>sf", telescope_functions_colored, {
  desc = "Funciones coloreadas (Tree-sitter)",
})

vim.keymap.set('n', '<leader>sc', function()
  builtin.lsp_document_symbols({ symbols = { "class" } })
end, { desc = "LSP Symbols: Classes" })

vim.keymap.set('n', '<leader>si', function()
  builtin.lsp_document_symbols({ symbols = { "interface" } })
end, { desc = "LSP Symbols: Interfaces" })

vim.keymap.set('n', '<leader>sv', function()
  builtin.lsp_document_symbols({ symbols = { "variable" } })
end, { desc = "LSP Symbols: Variables" })

vim.keymap.set('n', '<leader>st', function()
  builtin.lsp_document_symbols({ symbols = { "type", "interface" } })
end, { desc = "LSP Symbols: Types" })
