vim.o.colorcolumn = '100' -- See `highlight ColorColumn`

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s). See `:h 'confirm'`
vim.o.confirm = true

vim.o.number = true
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UIEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:h 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true       -- Highlight the line where the cursor is on.
vim.o.scrolloff = 10          -- Keep this many screen lines above/below the cursor.
vim.o.list = true             -- Show <tab> and trailing spaces.

vim.o.selection = 'exclusive' -- Don't include newline in selection
vim.o.showmatch = true        -- Highlight matching parenthesis

vim.opt.spell = true
-- NOTE: Vim requires these to end in .add
vim.opt.spellfile = { '~/.vim/spell/shared.en.utf-8.add', '~/.vim/spell/custom.en.utf-8.add' }

vim.o.splitbelow = true

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2   -- Size of an indent
vim.opt.tabstop = 2      -- Number of spaces tabs count for
vim.opt.softtabstop = 2  -- Number of spaces tabs count for while editing

vim.opt.termguicolors = true

vim.diagnostic.config({
  jump = { float = true }
})
