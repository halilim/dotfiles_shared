local vscode = require('vscode')

vim.notify = vscode.notify

local normalMaps = {
  ["<C-j>"] = "editor.action.marker.next",
  ["<C-k>"] = "editor.action.marker.prev",

  ["<leader><leader>j"] = "workbench.action.openSettingsJson",
  ["<leader><leader>jw"] = "workbench.action.openWorkspaceSettingsFile",
  ["<leader><leader>k"] = "workbench.action.openGlobalKeybindingsFile",

  ["<leader>%"] = "editor.emmet.action.matchTag",
  ["<leader>a"] = "alternate.alternateFile",
  ["<leader>cp"] = "copy-relative-path-and-line-numbers.both",
  ["<leader>da"] = "workbench.action.closeAllEditors",
  ["<leader>de"] = "workbench.action.closeOtherEditors",
  ["<leader>f"] = "workbench.action.quickOpen",
  ["<leader>rn"] = "editor.action.rename",
  ["<leader>t"] = "workbench.action.gotoSymbol",
  ["<leader>T"] = "workbench.action.showAllSymbols",

  ["g]"] = "editor.action.peekDefinition",
  ["K"] = "editor.action.showDefinitionPreviewHover",
  ["u"] = "undo",
  ["<C-r>"] = "redo",
  ["zg"] = "cSpell.addWordToDictionary",
}

for map, action in pairs(normalMaps) do
  vim.keymap.set({ "n" }, map, function() vscode.action(action) end)
end

normalVisualMaps = {
  ["<leader>c<space>"] = "editor.action.commentLine",
}

for map, action in pairs(normalVisualMaps) do
  vim.keymap.set({ "n", "v" }, map, function() vscode.action(action) end)
end
