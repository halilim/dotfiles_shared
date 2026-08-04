-- Automatically clean up trailing whitespaces every time a file is saved
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  callback = function()
    local save_cursor = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save_cursor)
  end,
})

-- Don't save lua files with errors (especially init.lua, for safe restart)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function(args)
    local errors = vim.diagnostic.get(args.buf, { severity = vim.diagnostic.severity.ERROR })
    if #errors > 0 then
      local err = errors[1]
      local row, col = err.lnum, err.col
      vim.api.nvim_win_set_cursor(0, { row, col })
      vim.notify(string.format('Error at %d:%d: %s', row, col, err.message), vim.log.levels.ERROR)
      -- FIXME: This is not actually aborting
      error() -- Abort write
    end
  end,
})

vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = true })
  end
})

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Create an autocommand group for Esc mappings
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
