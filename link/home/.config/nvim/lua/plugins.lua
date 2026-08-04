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
  { name = 'lspconfig',         src = 'https://github.com/neovim/nvim-lspconfig' },
  { name = 'lualine',           src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { name = 'mason',             src = 'https://github.com/mason-org/mason.nvim' },
  { name = 'mason-lspconfig',   src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
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
require('lazydev').setup()
require('lualine').setup({})
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'harper_ls', 'lua_ls', 'vimls' }
})
require('nvim-web-devicons').setup()
require('gitsigns').setup()
require('quicker').setup()

-- vim.lsp.config('harper_ls', { filetypes = { 'md' } })
-- vim.lsp.enable('harper_ls') -- Include in ftplugin files
vim.lsp.enable('lua_ls')
vim.lsp.enable('vimls')
