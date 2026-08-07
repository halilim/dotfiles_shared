vim.notify_os = function(msg, log_level, opts)
  local title = (opts and opts.title) and opts.title or 'Neovim'
  local cmd = {}

  if vim.fn.has('mac') == 1 then
    -- macOS Native AppleScript notification
    cmd = { 'osascript', '-e', string.format('display notification "%s" with title "%s"', msg, title) }
  elseif vim.fn.has('unix') == 1 then
    -- Linux Desktop notification (requires libnotify / notify-send installed)
    cmd = { 'notify-send', title, msg }
  elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    -- Windows PowerShell BurntToast or standard Toast balloon (Basic fallback)
    cmd = { 'powershell', '-Command', string.format(
      '[reflection.assembly]::loadwithpartialname("System.Windows.Forms"); [System.Windows.Forms.MessageBox]::Show("%s", "%s")',
      msg, title) }
  end

  if #cmd > 0 then
    vim.fn.jobstart(cmd, { detach = true })
  end
end
