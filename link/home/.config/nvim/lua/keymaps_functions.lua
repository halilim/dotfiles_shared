-- Close buffers
local function close_all_buffers(except_current)
  except_current = except_current or false
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    local name = vim.api.nvim_buf_get_name(buf)
    if (not except_current or buf ~= current_buf) and not name:match('^term://') and vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.cmd, 'bd ' .. buf)
    end
  end
end
vim.keymap.set('n', '<leader>da', close_all_buffers)
vim.keymap.set('n', '<leader>de', function() close_all_buffers(true) end)
vim.keymap.set('n', '<leader>do', function() close_all_buffers(true) end)


-- Close help, terminal, and quickfix buffers with Esc
local esc_close_group = vim.api.nvim_create_augroup('EscCloseBuffers', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = esc_close_group,
  -- Add any other filetypes you want to include to this list
  pattern = { 'terminal', 'help', 'qf' },
  callback = function()
    -- { buffer = true } ensures the mapping only applies to the matching filetype
    vim.keymap.set('n', '<Esc>', function()
      local bufnr = vim.api.nvim_get_current_buf()

      -- If it's a help window, just close the window
      if vim.bo[bufnr].filetype == 'help' then
        vim.cmd('helpclose')
      else
        -- Switches to previous buffer, then deletes the target buffer safely
        vim.cmd('bp | bd #')
      end
    end, { buffer = true, silent = true, desc = 'Close buffer keeping layout' })
  end,
})

-- Delete FILE and close buffer
-- https://stackoverflow.com/a/39360896/372654
vim.keymap.set('n', '<leader>rm', function()
  local file = vim.fn.expand('%:p')
  if vim.fn.isdirectory(file) ~= 0 then
    print("DeleteFileAndCloseBuffer: " .. file .. " is not a file")
  else
    local choice = vim.fn.confirm("Delete " .. file .. " and close buffer?", "&Delete\n&Cancel", 1)
    if choice == 1 then
      vim.fn.delete(file)
      vim.cmd('bdelete')
    end
  end
end)

-- FZF
local function get_visual_selection()
  if vim.api.nvim_get_mode().mode == 'v' then
    local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = 'v' })
    return table.concat(lines, '\n')
  end
end

local function my_fzf()
  local cwd = vim.fn.getcwd()
  if cwd == HOME then cwd = DOTFILES end -- Never open the whole home directory

  local query = get_visual_selection()
  query = string.match(query, '^%s*(.-)%s*$')

  FzfLua.files({ cwd = cwd, query = query })
end

vim.keymap.set({ 'n', 'i', 'v' }, '<C-p>', my_fzf) -- iTerm2hex: Cmd+P, 0x10
vim.keymap.set({ 'n', 'i', 'v' }, '<D-p>', my_fzf)
-- End: FZF
