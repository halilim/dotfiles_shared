-- Automatically disable search highlighting after 'updatetime' and when going to insert mode.
vim.cmd('packadd! nohlsearch')

vim.pack.add({
  { name = 'auto-session',      src = 'https://github.com/rmagatti/auto-session' },
  { name = 'blink.cmp',         src = 'https://github.com/saghen/blink.cmp',              version = vim.version.range('1.0') },
  { name = 'devicons',          src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { name = 'friendly-snippets', src = 'https://github.com/rafamadriz/friendly-snippets' },
  { name = 'fzf-lua',           src = 'https://github.com/ibhagwan/fzf-lua' },
  { name = 'gitsigns',          src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { name = 'lazydev',           src = 'https://github.com/folke/lazydev.nvim' },
  { name = 'lualine',           src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { name = 'quicker',           src = 'https://github.com/stevearc/quicker.nvim' },
  { name = 'surround',          src = 'https://github.com/kylechui/nvim-surround' },
})

require('auto-session').setup()

require('fzf-lua').setup({
  actions = {
    files = {
      ['enter'] = FzfLua.actions.file_tabedit,
    }
  },
  fzf_colors = true
})

require('gitsigns').setup()
require('lazydev').setup()
require('lualine').setup({})
require('nvim-web-devicons').setup()
require('quicker').setup()
