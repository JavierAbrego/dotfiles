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

vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
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
