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
