local M = {}
local config = require("peep.config")
local state = require("peep.state")

local extmarks = {}
local key_ns, extmark_ns, preview_ns

local function reset_state()
    state.src_buf = nil
    state.src_win = nil
    state.in_op = false
    state.is_showing = false
end

-- Label relative line number
local function place_extmark(buf, row, col, text, hl)
    local ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, buf, extmark_ns, row, col,
        {
            virt_text = { { text, hl } },
            virt_text_pos = "overlay"
        })
    if ok then table.insert(extmarks, mark_id) end
end

local function get_cursor_info()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local cursor = vim.api.nvim_win_get_cursor(win)
    local topline = vim.fn.line("w0", win)
    local botline = vim.fn.line("w$", win)
    local win_height = vim.api.nvim_win_get_height(win)
    return {
        win = win,
        buf = buf,
        row = cursor[1],
        col = cursor[2],
        topline = topline,
        botline = botline,
        win_height = win_height,
    }
end

local function attach_key_handler()
    local repeat_value = 0

    key_ns = vim.on_key(function(key)
        local num = tonumber(key)
        -- only nil and false is falsy, wtf
        if not num then
            M.clear()
            return
        end

        if not config.peep.line_preview then
            return
        end

        repeat_value = repeat_value * 10 + num

        local info = get_cursor_info()
        local center = info.row - 1
        local line_count = vim.api.nvim_buf_line_count(state.src_buf)

        local start_line = math.max(0, center - repeat_value)
        local end_line = math.min(center + repeat_value, line_count)

        -- print("ns", extmark_ns)
        -- print("buf", state.src_buf)
        -- print("clear from", info.row - repeat_value, "to", info.row + repeat_value)
        vim.api.nvim_buf_clear_namespace(state.src_buf, extmark_ns, 0, -1)
        vim.api.nvim_buf_clear_namespace(state.src_buf, preview_ns, 0, -1)

        for i = 1, repeat_value do
            local up = center - i
            local down = center + i

            vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, start_line, 0, {
                virt_text = { { "▲", "Preview" } },
                virt_text_pos = "overlay",
            })

            vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, end_line, 0, {
                virt_text = { { "▼", "Preview" } },
                virt_text_pos = "overlay",
            })
            if up >= 0 then
                vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, up, 0, {
                    end_line = up + 1,
                    hl_group = "Preview",
                    hl_eol = true,
                })
                if up ~= start_line then
                    vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, up, 0, {
                        virt_text = { { "│", "Preview" } },
                        virt_text_pos = "overlay",
                    })
                end
            end

            if down < line_count then
                vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, down, 0, {
                    end_line = down + 1,
                    hl_group = "Preview",
                    hl_eol = true,
                })
                if down ~= end_line then
                    vim.api.nvim_buf_set_extmark(state.src_buf, preview_ns, down, 0, {
                        virt_text = { { "│", "Preview" } },
                        virt_text_pos = "overlay",
                    })
                end
            end
        end

        vim.cmd("redraw")
    end)
end

function M.show() -- show
    extmark_ns = vim.api.nvim_create_namespace("extmarks")
    preview_ns = vim.api.nvim_create_namespace("preview")

    -- highlight groups
    vim.api.nvim_set_hl(0, "Main", { fg = config.colors.label_main.fg, bg = config.colors.label_main.bg, bold = true })
    vim.api.nvim_set_hl(0, "Sub", { fg = config.colors.label_sub.fg, bg = config.colors.label_sub.bg, bold = true })
    vim.api.nvim_set_hl(0, "Aux", { fg = config.colors.line_aux.fg, bold = true })
    vim.api.nvim_set_hl(0, "Preview", { fg = config.colors.line_preview.fg, bold = true, })

    -- vim.api.nvim_set_hl(0, "Preview", { bg = config.colors.line_preview.bg })

    local info = get_cursor_info()

    state.src_win = info.win
    state.src_buf = info.buf

    local start_row = info.row - info.win_height
    local end_row = info.row + info.win_height

    attach_key_handler()

    for row = start_row, end_row do
        local lines = vim.api.nvim_buf_get_lines(state.src_buf, row - 1, row, false)
        local line = lines[1] or "" -- avoid nil
        local cur_line_width = #line

        if row ~= info.row then
            local rel = math.abs(row - info.row)
            local last_char = line:find("%s*$") - 1
            local first_char = (line:find("%S") or 0) - 1
            local label_width = rel >= 100 and 3 or (rel >= 10 and 2 or 1)

            -- Vertical label
            place_extmark(state.src_buf, row - 1, info.col, tostring(rel), "Main")

            -- line end label
            if last_char > 1 and last_char < info.col then
                place_extmark(state.src_buf, row - 1, last_char, tostring(rel), "Sub")

                -- auxline from last char to cursor_col
                -- if condition is not needed because the following loop won't be triggered
                -- unless cursor_col > last_char
                for col = last_char + label_width, info.col - 1 do
                    place_extmark(state.src_buf, row - 1, col, config.peep.auxline_icon, "Aux")
                end
            else
                if info.col + label_width * 2 < first_char and first_char > 1 then
                    place_extmark(state.src_buf, row - 1, first_char - label_width, tostring(rel), "Sub")

                    -- auxline from lal > last_char
                    for col = info.col + label_width, first_char - 1 - label_width do
                        place_extmark(state.src_buf, row - 1, col, config.peep.auxline_icon, "Aux")
                    end
                end
            end
        else
            if config.peep.column then
                local start_col = 0
                local end_col = cur_line_width

                for col = start_col, end_col do
                    local rel = math.abs(col - info.col)
                    if rel % 10 == 0 then
                        place_extmark(state.src_buf, row - 1, col, tostring(rel), "Main")
                    end
                end
            end
        end
    end
end

function M.clear()
    if state.src_buf and extmark_ns then
        vim.api.nvim_buf_clear_namespace(state.src_buf, extmark_ns, 0, -1)
    end

    if state.src_buf and preview_ns then
        vim.api.nvim_buf_clear_namespace(state.src_buf, preview_ns, 0, -1)
    end

    extmarks = {}
    -- reset state
    reset_state()

    -- disable on_key
    if key_ns ~= nil then
        vim.on_key(nil, key_ns)
        key_ns = nil
    end
end

return M
