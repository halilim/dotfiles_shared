-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','

require('options')
require('highlight/highlight')
require('highlight/unicode')
require('keymaps')
require('auto_cmds')
require('plugins')
require('lsp')

require('jump')
require('utils')
