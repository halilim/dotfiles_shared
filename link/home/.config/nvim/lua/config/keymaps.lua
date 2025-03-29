-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", ".", function() require("dial.map").manipulate("increment", "normal") end)
vim.keymap.set("v", ".", function() require("dial.map").manipulate("increment", "visual") end)
