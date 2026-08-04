-- 1. Define the appearance for invisible characters
vim.api.nvim_set_hl(0, 'InvisibleUnicode', {
  bg = '#5f0000',
  fg = '#ff5f5f',
  bold = true,
  undercurl = true
})

-- 2. Define the regex pattern for invisible/ambiguous Unicode ranges
-- Covers: Invisible, Ambiguous, Problematic/Security, Invalid/Non-Character (from the output of unicode_test_gen.py)
-- local invisible_pattern = [[\%u200b\|\%u200c\|\%u200d\|\%ufeff\|\%ua0\|\%uad]]
local invisible_pattern = [[
  \[\%u0000-\%u001f\]\|\[\%u007f-\%u009f\]\|\[\%ud800-\%udfff\]\|\[-󠁿\]\|\%u200b\|\%u200c\|\%u200d\|\%ufeff\|\%u00a0\|\%u00ad\|\%u202e\|\%u202a\|\%u202c\|\%uffff
]]

-- 3. Auto-apply the highlight pattern across buffers
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
  pattern = '*',
  callback = function(args)
    -- Prevent matching in special buffers like terminal or NvimTree
    if vim.bo[args.buf].buftype ~= '' then return end

    -- Apply the match and store it to avoid duplicate triggers
    if not vim.w.invisible_unicode_match_id then
      vim.w.invisible_unicode_match_id = vim.fn.matchadd('InvisibleUnicode', invisible_pattern)
    end
  end,
})

-- TODO: Add homoglyph/confusable pairs (like Latin and Cyrillic lookalikes) to this list structure
