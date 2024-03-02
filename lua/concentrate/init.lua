-- can have multiple folds!
-- which means that we need to clean up the rows,
--
-- BUT we can have kind of a stack of folds, so we can "dig deeper" in our coding
--
local plenary = require("plenary.reload")

local vc = vim.cmd
local va = vim.api

local getpos = vim.fn.getpos
local M = {}

-- TODO let the user change these
M.folds = {
    { "j", "k" },
    { "h", "l" },
    { "u", "i" },
    { "y", "o" },
    { "n", "m" },
}
M.CURRENT_FOLD = 0

local function unfold_row(pos)

    if vim.fn.foldlevel(pos[1]) == 0 then
        return;
    end

    va.nvim_win_set_cursor(0, pos)
    vc("norm zd")
end

local function next_marks()

    if M.CURRENT_FOLD >= vim.fn.len(M.folds) then
        print("no more marks! if you want more, extend the number of marks in your setup()")
        return;
    end

    M.CURRENT_FOLD = M.CURRENT_FOLD + 1
    local marks = M.folds[M.CURRENT_FOLD]

    return marks
end

local function get_current_and_decrement_fold_marks()

    if M.CURRENT_FOLD < 1 then
        print("No folds!")
        return;
    end

    local marks = M.folds[M.CURRENT_FOLD]
    M.CURRENT_FOLD = M.CURRENT_FOLD - 1

    return marks
end

local function fold(from, to)
    vim.cmd(from .. ", " .. to .. " fo")
end

local function fold_lines(top_row, bot_row)
    -- get next mark names
    local marks = next_marks()

    if marks == nil then
        return;
    end

    fold("0", top_row)
    -- set mark
    vim.api.nvim_buf_set_mark(0, marks[1], top_row, 0, {})

    fold(bot_row, "$")
    -- set mark
    va.nvim_buf_set_mark(0, marks[2], bot_row, 0, {})
end

vim.keymap.set({ "n", "v", "x" }, "<leader>te", function()

    local selection_start = vim.fn.max({1, vim.fn.getpos("v")[2] - 1})
    local selection_end = vim.fn.min({va.nvim_win_get_cursor(0)[1] + 1, va.nvim_buf_line_count(0)})

    fold_lines(selection_start, selection_end)

    local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)

end)

M.remove_last_fold = function ()

    local cur_pos = va.nvim_win_get_cursor(0)
    local marks = get_current_and_decrement_fold_marks()

    if marks == nil then
        return;
    end
    -- go to top mark
    local m1 = getpos("'" .. marks[1])
    unfold_row({m1[2], 0 })
    vim.api.nvim_buf_set_mark(0, marks[1], 0, 0, {})

    local m2 = getpos("'" .. marks[2])
    unfold_row({m2[2], 0})
    vim.api.nvim_buf_set_mark(0, marks[2], 0, 0, {})

    -- return to position and center
    va.nvim_win_set_cursor(0, cur_pos)
    vc("norm zz")
end


vim.keymap.set({ "n", "v", "x" }, "<leader>tr", M.remove_last_fold)

M.remove_all_folds = function ()
    for _=M.CURRENT_FOLD, 0, -1 do
        M.remove_last_fold()
    end
end

vim.keymap.set({ "n", "v", "x" }, "te", M.remove_all_folds)
vim.keymap.set("n", "rel", function()

    vc(":w")

    plenary.reload_module("concentrate")

    return require("concentrate")
end)

return M