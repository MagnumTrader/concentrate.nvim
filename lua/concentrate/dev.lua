-- here i store my stuff
local plenary = require("plenary.reload")

local vc = vim.cmd

vim.keymap.set("n", "rel", function()

    vc(":w")

    plenary.reload_module("concentrate")

    return require("concentrate")
end)

vim.keymap.set({ "n", "v", "x" }, "te", M.remove_all_folds)
vim.keymap.set({ "n", "v", "x" }, "<leader>tr", M.remove_last_fold)
