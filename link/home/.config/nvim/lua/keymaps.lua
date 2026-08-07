-- iTerm2hex: Convert Cmd to Ctrl. (Keys | Profiles > Keys) > Key Bindings > + :
--   Keyboard Shortcut: ?
--   Action: Send Hex Code
--   Value: 0x...

vim.keymap.set('n', '<D-M-Left>', '<cmd>-tabmove<cr>')
vim.keymap.set('n', '<D-M-Right>', '<cmd>+tabmove<cr>')

vim.keymap.set('n', '<leader><leader>k', '<cmd>tabedit ' .. NVIM_CONFIG_DIR .. '/lua/keymaps.lua<cr>')
vim.keymap.set('n', '<leader><leader>r', '<cmd>restart<cr>')
vim.keymap.set('n', '<leader><leader>v', '<cmd>tabedit $MYVIMRC<cr>')
-- TODO: Convert to nvim/custom.lua
vim.keymap.set('n', '<leader><leader>vc', '<cmd>tabedit $DOTFILES_CUSTOM/link/home/.vim/autoload/custom.vim<cr>')

vim.keymap.set('n', '<leader><space>', '<cmd>nohlsearch<cr>')

for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt<cr>')
  vim.keymap.set('n', '<D-' .. i .. '>', i .. 'gt<cr>')
end

vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<cr>') -- iTerm2hex: Cmd+S, 0x13

-- Ctrl+Shift+T, Re-open last (like in browsers)
-- TODO: Not working
-- vim.keymap.set('n', '<C-T>', '<cmd>e#<cr>', { remap = true })
-- vim.keymap.set('n', '<C-T>', '<cmd>browse old<cr>1<cr>', { remap = true })
-- vim.keymap.set('n', '<leader>ro', '<cmd>browse old<cr>1<cr>')

-- nerdcommenter muscle memory artifacts
vim.keymap.set('n', '<leader>c', 'gcc', { remap = true, desc = 'Toggle comment line' })
vim.keymap.set('v', '<leader>c', 'gc', { remap = true, desc = 'Toggle comment selected lines' })

vim.keymap.set('n', '<leader>q', '<cmd>qa<cr>')
vim.keymap.set('n', '<leader>x', '<cmd>x<cr>')

vim.keymap.set('n', 'q', '<cmd>bd<cr>')
