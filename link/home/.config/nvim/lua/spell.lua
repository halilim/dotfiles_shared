vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }
-- NOTE: Vim requires these to end in .add
vim.opt.spellfile = {
  HOME .. '/.vim/spell/shared.en.utf-8.add',
  HOME .. '/.vim/spell/custom.en.utf-8.add'
}

function Lang_specific_spell(lang)
  local current_spell = vim.bo.spellfile
  local custom_spell = HOME .. '/.vim/spell/' .. lang .. '.utf-8.add'

  -- If spellfile already has values, combine them; otherwise just set it
  if current_spell ~= '' then
    vim.opt_local.spellfile = current_spell .. ',' .. custom_spell
  else
    vim.opt_local.spellfile = custom_spell
  end
end

-- TODO: Add project-specific spellfile support. For example, add a `shared.en.utf-8.add` file to the `shared` repo and add it to the spellfile list above.
