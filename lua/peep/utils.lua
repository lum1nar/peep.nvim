local U = {};

local function clone_buffer(state, src_buf)
    local win_width = vim.o.columns

    local win = vim.api.nvim_get_current_win()
    state.topline = vim.fn.line("w0", win)
    state.botline = vim.fn.line("w$", win)
    -- print(top .. "-" .. bot)

    local new_buf = vim.api.nvim_create_buf(false, true)
    state.last_buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.api.nvim_buf_get_lines(src_buf, state.topline - 1, state.botline, false)

    -- make a copy befor padding
    vim.api.nvim_buf_set_lines(state.last_buf, 0, -1, false, lines)

    for i, line in ipairs(lines) do
        lines[i] = lines[i] .. string.rep(" ", win_width - #lines[i])
    end

    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)

    -- for syntax highlighting
    local ft = vim.bo[src_buf].filetype
    vim.bo[new_buf].filetype = ft

    vim.bo[new_buf].modifiable = false
    vim.bo[new_buf].bufhidden = "wipe"

    return new_buf
end

local function is_visual_mode()
    local m = vim.fn.mode()
    -- vim.notify("mode" .. m)
    return m == "v" or m == "V" or m == ""
end

U.win_close = function(state)
    -- Record the last cursor pos in peep_win
    local peep_cursor = vim.api.nvim_win_get_cursor(state.peep_win)

    -- set is_showing to false first to prevent prevent M.clear() from triggering twice on Winclose(vim.api.nvim_win_close)
    state.is_showing = false

    vim.api.nvim_win_close(state.peep_win, true)

    -- reposition the cursor after closing peep_win
    local win = vim.api.nvim_get_current_win()
    local topline = vim.fn.line("w0", win)

    -- recover visual selection
    if state.was_visual then
        vim.cmd([[ execute "normal! gv" ]])
    end

    -- reposition the cursor after closing peep_win
    vim.api.nvim_win_set_cursor(state.src_win, { topline + peep_cursor[1] - 1, peep_cursor[2] })
end

U.win_open = function(state)
    -- record visual selection
    state.was_visual = is_visual_mode()
    if state.was_visual then
        vim.cmd([[ execute "normal! \<ESC>" ]])
    end

    state.src_win = vim.api.nvim_get_current_win()
    state.src_buf = vim.api.nvim_win_get_buf(state.src_win)
    local topline = vim.fn.line("w0", state.src_win)

    local win_width = vim.api.nvim_win_get_width(state.src_win)
    local win_height = vim.api.nvim_win_get_height(state.src_win)

    state.peep_buf = clone_buffer(state, state.src_buf)
    local peep_cfg = {
        relative = "win",    -- 相對於 src_win
        win = state.src_win, -- 指定要覆蓋的 window
        width = win_width,
        height = win_height,
        row = 0,
        col = 0,
        style = "minimal",
        focusable = true,
        border = "none",
    }

    -- local cfg = vim.api.nvim_win_get_config(state.src_win)
    --
    -- for index, value in pairs(cfg) do
    --     print(index, value)
    -- end

    local cursor = vim.api.nvim_win_get_cursor(state.src_win)

    state.peep_win = vim.api.nvim_open_win(
        state.peep_buf,
        true,
        peep_cfg
    )

    -- show number
    vim.api.nvim_win_set_option(state.peep_win, "number", true)

    -- try to clone identical buffer config
    local buf_options = {
        "tabstop", "shiftwidth", "expandtab",
        "textwidth", "filetype", "syntax",
    }

    for _, opt in ipairs(buf_options) do
        vim.api.nvim_buf_set_option(state.peep_buf, opt,
            vim.api.nvim_buf_get_option(state.src_buf, opt))
    end

    -- try to clone same win config
    local win_options = {
        "number", "relativenumber", "cursorline",
        "wrap", "linebreak", "breakindent",
        "signcolumn", "colorcolumn", "foldenable",
    }

    for _, opt in ipairs(win_options) do
        vim.api.nvim_win_set_option(state.peep_win, opt,
            vim.api.nvim_win_get_option(state.src_win, opt))
    end

    -- move to the same cursor position as the one in src_buf
    vim.api.nvim_win_set_cursor(state.peep_win, { cursor[1] - topline + 1, cursor[2] })
end

U.log = function(state, key)
    table.insert(state.keylog, key)
    -- print("pressed", key)
end

return U
