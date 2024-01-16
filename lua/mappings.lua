local map = vim.keymap.set
local cmd = vim.cmd

local function set()
  map({ 'n', 'v' }, '<leader>', '<Nop>', { desc = 'Leader', silent = true })

  -- General
  map('n', '<C-s>', cmd.w, { desc = 'Save' })

  -- Nvimtree
  map('n', '<leader>tt', cmd.NvimTreeToggle, { desc = 'Toggle [t]ree' })
  map('n', '<leader>h', cmd.NvimTreeFocus, { desc = '[h] Focus Tree' })

  -- Undotree
  map('n', '<leader>tu', cmd.UndotreeToggle, { desc = 'Toggle [u]ndotree' })

  -- Bufferline
  map('n', '<Tab>', cmd.BufferLineCycleNext, { desc = 'Next Buffer' })
  map('n', '<S-Tab>', cmd.BufferLineCyclePrev, { desc = 'Prev Buffer' })
  map('n', '<leader>w', cmd.bd, { desc = '[w] Close Buffer' })

  -- UFO
  local ufo = require 'ufo'
  map('n', 'zO', ufo.openAllFolds, { desc = '[O]pen all folds' })
  map('n', 'zC', ufo.closeAllFolds, { desc = '[C]lose all folds' })

  -- Comment
  map('n', '<leader>//', function()
    require('Comment.api').toggle.linewise.current()
  end, { desc = '[//] Comment current line' })
  map('v', '<leader>//', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>")

  -- Diagnostic keymaps
  map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous [d]iagnostic' })
  map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next [d]iagnostic message' })
  map('n', '<leader>e', vim.diagnostic.open_float, { desc = '[e] Open diagnostic' })
  map('n', '<leader>d', vim.diagnostic.setloclist, { desc = 'Open [d]iagnostics list' })

  -- Which key
  local key = require 'which-key'
  key.register {
    ['<leader>g'] = { name = '[g]it', _ = 'which_key_ignore' },
    ['<leader>s'] = { name = '[s]earch', _ = 'which_key_ignore' },
    ['<leader>t'] = { name = '[t]oggle', _ = 'which_key_ignore' },
    ['<leader>l'] = { name = '[L]SP', _ = 'which_key_ignore' },
  }
  key.register({
    ['<leader>'] = { name = 'VISUAL <leader>' },
  }, { mode = 'v' })

  -- Telescope
  local t = require 'telescope.builtin'
  map('n', '<leader>?', t.oldfiles, { desc = '[?] Find recently opened files' })
  map('n', '<leader><space>', t.buffers, { desc = '[ ] Find existing buffers' })
  map('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    t.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  map('n', '<leader>s/', cmd.LiveGrepOpenFiles, { desc = '[s]earch [/] in Open Files' })
  map('n', '<leader>ss', t.builtin, { desc = '[s]earch [s]elect Telescope' })
  map('n', '<leader>gf', t.git_files, { desc = 'Search [g]it [f]iles' })
  map('n', '<leader>sf', t.find_files, { desc = '[s]earch [f]iles' })
  map('n', '<leader>sh', t.help_tags, { desc = '[s]earch [h]elp' })
  map('n', '<leader>sg', t.live_grep, { desc = '[s]earch by [g]rep' })
  map('n', '<leader>sG', cmd.LiveGrepGitRoot, { desc = '[s]earch by [G]rep on Git Root' })
  map('n', '<leader>sd', t.diagnostics, { desc = '[s]earch [d]iagnostics' })
  map('n', '<leader>sr', t.resume, { desc = '[s]earch [r]esume' })

  -- Highlight on yank
  local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
  })
end

local function git_mapping(bufnr)
  local function bmap(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    map(mode, l, r, opts)
  end

  local gs = package.loaded.gitsigns
  bmap('v', '<leader>gr', function()
    gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = '[r]eset hunk' })

  bmap('n', '<leader>gr', gs.reset_hunk, { desc = '[r]eset hunk' })
  bmap('n', '<leader>gR', gs.reset_buffer, { desc = '[R]eset buffer' })
  bmap('n', '<leader>gb', function()
    gs.blame_line { full = false }
  end, { desc = '[b]lame line' })
  bmap('n', '<leader>gd', function()
    gs.diffthis '~'
  end, { desc = '[d]iff against last commit' })
end

local function cmp_mapping()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  return cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }
end

local function lsp_mapping(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>ln', vim.lsp.buf.rename, 'Re[n]ame')
  nmap('<leader>la', vim.lsp.buf.code_action, 'Code [a]ction')
  local t = require 'telescope.builtin'
  nmap('<leader>ld', t.lsp_definitions, 'Goto [d]efinition')
  nmap('<leader>lr', t.lsp_references, 'Goto [r]eferences')
  nmap('<leader>li', t.lsp_implementations, 'Goto [i]mplementation')
  nmap('<leader>lD', t.lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ls', t.lsp_document_symbols, '[s]ymbols')
  nmap('<leader>lw', t.lsp_workspace_symbols, '[w]orkspace symbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
end

local ts_mapping = {
  go_next_start = {
    [']m'] = '@function.outer',
    [']]'] = '@class.outer',
  },
  go_next_end = {
    [']M'] = '@function.outer',
    [']['] = '@class.outer',
  },
  go_previous_start = {
    ['[m'] = '@function.outer',
    ['[['] = '@class.outer',
  },
  go_previous_end = {
    ['[M'] = '@function.outer',
    ['[]'] = '@class.outer',
  },
}

return {
  set = set,
  cmp = cmp_mapping,
  git = git_mapping,
  lsp = lsp_mapping,
  ts = ts_mapping,
}
