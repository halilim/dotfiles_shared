local current_spell = vim.bo.spellfile
local custom_spell = '~/.vim/spell/vim.utf-8.add'

-- If spellfile already has values, combine them; otherwise just set it
if current_spell ~= '' then
  vim.opt_local.spellfile = current_spell .. ',' .. custom_spell
else
  vim.opt_local.spellfile = custom_spell
end
