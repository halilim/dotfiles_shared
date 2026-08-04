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
