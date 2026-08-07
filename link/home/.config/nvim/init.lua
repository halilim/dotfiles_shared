DOTFILES = vim.env.DOTFILES
HOME = vim.fn.expand('~')
NVIM_CONFIG_DIR = vim.fn.stdpath('config')

-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ','

require('auto_cmds')
require('highlight/highlight')
require('highlight/unicode')
require('jump')
require('keymaps_functions')
require('keymaps')
require('lsp')
require('options')
require('plugins')
require('spell')
require('utils')
