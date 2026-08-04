vim.pack.add({
  { name = 'lspconfig',       src = 'https://github.com/neovim/nvim-lspconfig' },
  { name = 'mason',           src = 'https://github.com/mason-org/mason.nvim' },
  { name = 'mason-lspconfig', src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
})

local harper_file_types = { 'markdown', 'text', 'tex', 'typst' }

-- TODO: `linters` are not recognized. Create an issue at https://github.com/Automattic/harper.
--       Add note that `filetypes` are not recognized. Add links:
--         - https://github.com/mason-org/mason-lspconfig.nvim
--         - https://github.com/neovim/nvim-lspconfig
--         - https://writewithharper.com/docs/integrations/neovim#Native-Neovim-LSP-Config
vim.lsp.config('harper_ls', {
  filetypes = harper_file_types,
  settings = {
    ['harper-ls'] = {
      linters = {
        ExpandConfiguration = false,
        ExpandMemoryShorthands = false,
        ToDoHyphen = false,
      }
    }
  }
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = harper_file_types,
  callback = function()
    vim.opt_local.spell = false
  end,
})

local lsp_ensure_installed = { 'vimls' }

if not vim.env.TERMUX_VERSION then
  table.insert(lsp_ensure_installed, 'harper_ls')

  -- Available as `pkg install lua-language-server` in Termux
  table.insert(lsp_ensure_installed, 'lua_ls')
end

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = lsp_ensure_installed
})
