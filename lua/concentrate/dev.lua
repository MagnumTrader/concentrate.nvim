-- here i store my stuff
local plenary = require("plenary.reload")
vim.keymap.set("n", "rel", function()

    vim.cmd(":w")
    plenary.reload_module("concentrate")

    return require("concentrate")

end)
