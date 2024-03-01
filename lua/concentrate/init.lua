-- can have multiple folds!
-- which means that we need to clean up the rows, 
--
-- BUT we can have kind of a stack of folds, so we can "dig deeper" in our coding
--
local plenary = require("plenary.reload")

local vc = vim.cmd
local va = vim.api

local M = {}

-- TODO check for fold conflicts
M.folds = {
        {"j", "k"},
        {"h", "l"},
        {"u", "o"},
}
M.CURRENT_FOLD = 0

local function unfold_row(pos)
    va.nvim_win_set_cursor(0, pos)
    vc("norm zd")
end
local function next_marks()
    if M.CURRENT_FOLD >= vim.fn.len(M.folds) then
        print("no more marks! extend number of marks in your setup()")
        return;
    end

    M.CURRENT_FOLD = M.CURRENT_FOLD + 1
    local marks = M.folds[M.CURRENT_FOLD]

    return marks
end

local function prev_marks()
    if M.CURRENT_FOLD < 1 then
        print("at first mark!")
        return;
    end

    local marks = M.folds[M.CURRENT_FOLD]
    M.CURRENT_FOLD = M.CURRENT_FOLD - 1

    return marks
end

local function fold_top(line)

    if line < 1 then
        return;
    end

    va.nvim_win_set_cursor(0, {line, 0})
    vc("norm zfgg")
end

local function fold_bottom(line)
    va.nvim_win_set_cursor(0, {line, 0})
    vc("norm zfG")
end

-- better to use both fold functions and just pass lines to fold from
local function single_line_fold()
    -- get current cursor position
    local cur_pos = va.nvim_win_get_cursor(0)
    local bot_fold = cur_pos[1] + 1
    local top_fold = cur_pos[1] - 1
    -- get next mark names
    local marks = next_marks()

    if marks == nil then
        return;
    end

    if top_fold >= 1 then
        fold_top(top_fold)
        -- set mark
        vim.api.nvim_buf_set_mark(0, marks[1], top_fold, 0, {})
    end

    fold_bottom(bot_fold)
    -- set mark
    va.nvim_buf_set_mark(0, marks[2], bot_fold, 0, {})
    va.nvim_win_set_cursor(0, cur_pos)
end

vim.keymap.set("n", "<leader>te", function ()
    single_line_fold()
end)

local function remove_last_folds()
    -- get current position
    local cur_pos = vim.api.nvim_win_get_cursor(0)
    local bot_fold = cur_pos[1] + 1
    local top_fold = cur_pos[1] - 1
    -- get the marks to remove
    local marks = prev_marks()

    if marks == nil then
        print("No folds to remove!")
        return;
    end

    local top_mark = vim.api.nvim_get_mark(marks[1], {})

    -- go to top mark

    -- remove fold
    -- remove top mark
    -- go to bot mark
    -- remove fold
    -- remove bot mark
    --
    --
    -- return to position
    -- center screen
end
vim.keymap.set("n", "<leader>tr", function ()

    local cur_pos = va.nvim_win_get_cursor(0)
    -- get first line
    --
    --get last mark
    local marks = prev_marks()

    if marks == nil then
        return;
    end

    unfold_row(vim.api.nvim_buf_get_mark(0, marks[1]))
    -- go to the line of the second mark
    -- unfold 
    unfold_row(vim.api.nvim_buf_get_mark(0, marks[2]))

    -- return to first line
    va.nvim_win_set_cursor(0, cur_pos)
end)

local function current_fold ()
    return M.folds[M.CURRENT_FOLD]
end




vim.keymap.set({"v", "x"}, "<leader>asdf", function()

    local vs_start = vim.fn.getpos("v")[2]
    local vs_end = vim.fn.getcurpos(0)[2]
end)

vim.keymap.set("n", "rel", function()

    -- for _, v in pairs(M.folds) do
    --     for _,m in ipairs(v) do
    --         vim.api.nvim_del_mark(m)
    --     end
    -- end


    vc(":w")
    print(vim.inspect(va.nvim_buf_get_mark(0, "a")))

    plenary.reload_module("concentrate")
    return require("concentrate")
end)

return M
