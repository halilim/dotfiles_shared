-- iTerm2hex: (Keys | Profiles > Keys) > Key Bindings > + :
--   Keyboard Shortcut: ?
--   Action: Send Hex Code
--   Value: 0x...

local config_dir = vim.fn.stdpath('config')

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

vim.keymap.set('n', '<leader><leader>k', '<cmd>tabedit ' .. config_dir .. '/lua/keymaps.lua<cr>')
vim.keymap.set('n', '<leader><leader>r', '<cmd>restart<cr>')
vim.keymap.set('n', '<leader><leader>v', '<cmd>tabedit $MYVIMRC<cr>')
-- TODO: Convert to nvim/custom.lua
vim.keymap.set('n', '<leader><leader>vc', '<cmd>tabedit $DOTFILES_CUSTOM/link/home/.vim/autoload/custom.vim<cr>')

vim.keymap.set('n', '<leader><space>', '<cmd>nohlsearch<cr>')

for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt<cr>')
  vim.keymap.set('n', '<D-' .. i .. '>', i .. 'gt<cr>')
end

local function close_all_buffers(except_current)
  except_current = except_current or false

  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf)
    -- Only close if it's not the current buffer AND not a terminal
    if (not except_current or buf ~= current_buf) and not name:match('^term://') and vim.api.nvim_buf_is_valid(buf) then
      -- Use "bd!" if you want to force close unsaved files
      pcall(vim.cmd, 'bd ' .. buf)
    end
  end
end

vim.keymap.set('n', '<leader>da', close_all_buffers)
vim.keymap.set('n', '<leader>de', function() close_all_buffers(true) end)
vim.keymap.set('n', '<leader>do', function() close_all_buffers(true) end)

local function get_visual_selection()
  if vim.api.nvim_get_mode().mode ~= 'v' then
    return ''
  end

  local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = 'v' })
  return table.concat(lines, '\n')
end

local function my_fzf()
  local cwd = vim.fn.getcwd()
  if cwd == vim.env.HOME then
    cwd = vim.env.DOTFILES
  end

  local query = get_visual_selection()
  query = string.match(query, '^%s*(.-)%s*$')

  FzfLua.files({ cwd = cwd, query = query })
end
vim.keymap.set({ 'n', 'i', 'v' }, '<C-p>', my_fzf)       -- iTerm2hex: Cmd+P, 0x10
vim.keymap.set({ 'n', 'i', 'v' }, '<D-p>', my_fzf)       -- iTerm2hex: Cmd+P, 0x10

vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<cr>') -- iTerm2hex: Cmd+S, 0x13

vim.keymap.set('n', '<C-T>', '<cmd>e#<cr>', { remap = true })

-- nerdcommenter muscle memory artifacts
vim.keymap.set('n', '<leader>c', 'gcc', { remap = true, desc = 'Toggle comment line' })
vim.keymap.set('v', '<leader>c', 'gc', { remap = true, desc = 'Toggle comment selected lines' })

vim.keymap.set('n', '<leader>q', '<cmd>qa<cr>')
vim.keymap.set('n', '<leader>x', '<cmd>x<cr>')

vim.keymap.set('n', 'q', '<cmd>bd<cr>')
