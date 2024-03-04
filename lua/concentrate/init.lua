local vc = vim.cmd
local va = vim.api
local getpos = vim.fn.getpos
require("concentrate.dev")

local M = {}
-- should save the settings for folding to restore them
M.colors = {
    bg = "#282e26",
    fg="#282e26"
}

M.fold_marks = {
    { "j", "k" },
    { "h", "l" },
    { "u", "i" },
    { "y", "o" },
    { "n", "m" },
}

M.CURRENT_FOLD = 0

-- TODO other settings
M.setup = function (settings)
    if settings.fold_marks then
        M.fold_marks = settings.fold_marks
    end
end

local function last_fold_marks()
    return M.fold_marks[M.CURRENT_FOLD]
end

local function current_focus_size()

    local last_marks = last_fold_marks()

    if last_marks == nil then
        return
    end

    local top_fold_row = va.nvim_buf_get_mark(0, last_marks[1])[1]
    local bot_fold_row = va.nvim_buf_get_mark(0, last_marks[2])[1]
    return bot_fold_row - top_fold_row

end

local function add_top_padding ()

    local cur_win = va.nvim_get_current_win()

    local win_height = va.nvim_win_get_height(0)
    local focus_size = current_focus_size()

    if focus_size == nil then
        print("no focus")
        return
    end

    local pad_height = math.floor((win_height - current_focus_size()) / 2)
    -- create both the windows and pad them
    -- set these to a column
    vc("new concentrate.padding")
    M.TOP_PADDING = va.nvim_get_current_win()
    va.nvim_win_set_height(0, pad_height)
    va.nvim_set_current_win(cur_win)

end

local function remove_top_padding()
    va.nvim_set_current_win(M.TOP_PADDING)
    va.nvim_buf_delete(0, {force=true})
end
local function unfold_row(pos)
    if vim.fn.foldlevel(pos[1]) == 0 then
        return;
    end
    va.nvim_win_set_cursor(0, pos)
    vc("norm zd")
end

local function next_marks()

    if M.CURRENT_FOLD >= vim.fn.len(M.fold_marks) then
        print("no more marks! if you want more, extend the number of marks in your setup()")
        return;
    end

    M.CURRENT_FOLD = M.CURRENT_FOLD + 1
    local marks = M.fold_marks[M.CURRENT_FOLD]

    return marks
end

local function get_current_and_decrement_fold_marks()

    if M.CURRENT_FOLD < 1 then
        print("No folds!")
        return;
    end

    local marks = M.fold_marks[M.CURRENT_FOLD]
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
    --- 
end


M.new_fold =  function()

    local selection_start = vim.fn.max({1, vim.fn.getpos("v")[2] - 1})
    local selection_end = vim.fn.min({va.nvim_win_get_cursor(0)[1] + 1, va.nvim_buf_line_count(0)})


    fold_lines(selection_start, selection_end)

    if M.TOP_PADDING == nil then
        add_top_padding()
    end
    local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)
end

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

    if M.CURRENT_FOLD == 0 then
        remove_top_padding()
        M.TOP_PADDING = nil
    end
    -- return to position and center
    va.nvim_win_set_cursor(0, cur_pos)
    vc("norm zz")
end

M.remove_all_folds = function ()

    for _=M.CURRENT_FOLD, 0, -1 do
        M.remove_last_fold()
    end
end


vim.keymap.set("n", "tw" , function ()
    -- remove windows
end)


vim.keymap.set({ "n", "v", "x" }, "tt", M.new_fold)
vim.keymap.set({ "n", "v", "x" }, "tr", M.remove_last_fold)
vim.keymap.set({ "n", "v", "x" }, "<leader>tr", M.remove_all_folds)

return M
