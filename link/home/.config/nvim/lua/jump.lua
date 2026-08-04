-- Helper function to evaluate and execute the closest jump in a given direction
local function jump_closest(direction)
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1]
  local current_col = current_pos[2]

  -- 1. Fetch LSP Diagnostic Error position
  local diag
  if direction == 'next' then
    diag = vim.diagnostic.get_next()
  else
    diag = vim.diagnostic.get_prev()
  end

  -- 2. Detect Spell Error position using a temporary 'ghost' jump
  local spell_cmd = direction == 'next' and 'silent! normal! ]s' or 'silent! normal! [s'
  vim.cmd(spell_cmd)
  local spell_pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, current_pos) -- Instantly restore cursor

  -- 3. Determine if valid targets exist ahead/behind
  local has_diag = diag ~= nil
  local diag_line = has_diag and (diag.lnum + 1) or nil
  local diag_col = has_diag and diag.col or nil

  local has_spell = false
  if direction == 'next' then
    if spell_pos[1] > current_line or (spell_pos[1] == current_line and spell_pos[2] > current_col) then
      has_spell = true
    end
  else
    if spell_pos[1] < current_line or (spell_pos[1] == current_line and spell_pos[2] < current_col) then
      has_spell = true
    end
  end

  -- 4. Compare distances and execute the closest jump
  if has_diag and has_spell then
    local diag_is_closer = false
    if direction == 'next' then
      if diag_line < spell_pos[1] or (diag_line == spell_pos[1] and diag_col < spell_pos[2]) then
        diag_is_closer = true
      end
    else
      if diag_line > spell_pos[1] or (diag_line == spell_pos[1] and diag_col > spell_pos[2]) then
        diag_is_closer = true
      end
    end

    if diag_is_closer then
      vim.diagnostic.jump({ diagnostic = diag, float = true })
    else
      vim.cmd(direction == 'next' and 'normal! ]s' or 'normal! [s')
    end
  elseif has_diag then
    vim.diagnostic.jump({ diagnostic = diag, float = true })
  elseif has_spell then
    vim.cmd(direction == 'next' and 'normal! ]s' or 'normal! [s')
  else
    vim.notify('No diagnostic or spelling errors found in that direction.', vim.log.levels.INFO)
  end
end

vim.keymap.set('n', '<C-j>', function() jump_closest('next') end, { desc = 'Next diagnostic or spell error' })
vim.keymap.set('n', '<C-k>', function() jump_closest('prev') end, { desc = 'Prev diagnostic or spell error' })
