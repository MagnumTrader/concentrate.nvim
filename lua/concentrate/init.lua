-- can have multiple folds!
-- which means that we need to clean up the rows, 
--
-- BUT we can have kind of a stack of folds, so we can "dig deeper" in our coding
--
local plenary = require("plenary.reload")

local vc = vim.cmd
local va = vim.api
local vo = vim.opt
local M = {}

-- skriver msa
--
--
--
--
--
--
-- redo this to only take row
local function move_cursor_to_row(row)
    va.nvim_win_set_cursor(0, {row, 0})
end

local function reset_folds()



    -- hejsan jag skriver commentarer

    if M.TOP_FOLD == nil then
        return
    end

    local cur_pos = va.nvim_win_get_cursor(0)
    move_cursor_to_row(M.TOP_FOLD)
    vc("norm zD")
    move_cursor_to_row(M.BOT_FOLD)
    vc("norm zD")

    move_cursor_to_row(cur_pos[1])
end

-- function when only one line is selected
vim.keymap.set("n", "asdf", function()

    local cur_pos = va.nvim_win_get_cursor(0)

    M.TOP_FOLD = cur_pos[1] - 1
    M.BOT_FOLD = cur_pos[1] + 1

    move_cursor_to_row(M.BOT_FOLD)
    vc("norm zfG")

    move_cursor_to_row(M.TOP_FOLD)
    vc("norm zfgg")

    -- move back
    move_cursor_to_row(cur_pos[1])
    vc("norm zz")
end)

vim.keymap.set({"v", "x"}, "asdf", function()

    local vs_start = vim.fn.getpos("v")[2]
    local vs_end = vim.fn.getcurpos(0)[2]


end)

vim.keymap.set("n", "rel", function()

    reset_folds()
    vc(":w")

    plenary.reload_module("concentrate")
    return require("concentrate")
end)

return M
