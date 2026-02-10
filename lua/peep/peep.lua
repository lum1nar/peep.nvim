local M = {}
local config = require("peep.config")
local state = require("peep.state")

local extmarks = {}
local key_ns, extmark_ns

function M.show() -- show
    local repeat_value = 0

    key_ns = vim.on_key(function(key)
        local is_num = false

        for i = 0, 9 do
            if tonumber(key) == i then
                -- vim.notify("It's a number'")
                is_num = true
                repeat_value = repeat_value * 10 + i
            end
            --
        end

        if not is_num then
            -- vim.notify("Cleaning up!")
            M.clear()
            return
        end
    end)

    extmark_ns = vim.api.nvim_create_namespace("Peep_ns")
    -- utils.win_open(state)
    state.is_showing = true
    vim.api.nvim_set_hl(0, "Main", { fg = config.colors.label_main.fg, bg = config.colors.label_main.bg, bold = true })
    vim.api.nvim_set_hl(0, "Sub", { fg = config.colors.label_sub.fg, bg = config.colors.label_sub.bg, bold = true })
    vim.api.nvim_set_hl(0, "Aux", { fg = config.colors.line_aux.fg, bold = true })

    state.src_win = vim.api.nvim_get_current_win()
    state.src_buf = vim.api.nvim_win_get_buf(state.src_win)

    local topline = vim.fn.line("w0", state.src_win)
    local botline = vim.fn.line("w$", state.src_win)

    local cursor = vim.api.nvim_win_get_cursor(state.src_win)
    local cursor_row, cursor_col = cursor[1], cursor[2]
    local win_height = vim.api.nvim_win_get_height(0)

    -- deal with unexpected close(:q, etc)
    -- vim.api.nvim_create_autocmd("WinClosed", {
    --     callback = function()
    --         M.clear(state)
    --     end,
    -- })

    extmarks = {}
    -- vim.notify("tset")

    -- vim.notify(tostring(win_height))
    -- print(win_height) local start_row = 1 local end_row = win_height
    -- print(start_row, end_row, cursor_row) local start_row = 1
    local start_row = cursor_row - win_height
    local end_row = cursor_row + win_height

    for row = start_row, end_row do
        local lines = vim.api.nvim_buf_get_lines(state.src_buf, row - 1, row, false)
        local line = lines[1] or "" -- avoid nil
        -- print(line)
        local cur_line_width = #line
        if row ~= cursor_row then
            local rel = math.abs(row - cursor_row)
            -- print(cur_line_width)
            local ok, ok2, ok3, ok4, mark_id, mark_id2, mark_id3, mark_id4
            --- search for the last non-space char
            -- print(row, #line)
            local last_char = line:find("%s*$") - 1
            local first_char = (line:find("%S") or 0) - 1
            -- vim.notify(tostring(last_char)) print(last_char)
            -- print(row, first_char)
            local label_width = 1

            if rel >= 10 then
                label_width = 2
            elseif rel >= 100 then
                label_width = 3
            end

            -- Vertical label
            ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1, cursor_col,
                {
                    virt_text = { { tostring(rel), "Main" } },
                    virt_text_pos = "overlay"
                })

            if ok then
                table.insert(extmarks, mark_id)
            end

            -- line end label
            if last_char > 1 and last_char < cursor_col then
                ok2, mark_id2 = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1, last_char,
                    {
                        virt_text = { { tostring(rel), "Sub" } },
                        virt_text_pos = "overlay"
                    })
                if ok2 then
                    table.insert(extmarks, mark_id2)
                end

                -- auxline from last char to cursor_col
                if cursor_col >= last_char then
                    for col = last_char + label_width, cursor_col - 1 do
                        ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1, col,
                            {
                                virt_text = { { config.peep.auxline_icon, "aux" } },
                                virt_text_pos = "overlay"
                            })
                        if ok3 then
                            table.insert(extmarks, mark_id3)
                        end
                    end
                end
            else
                if cursor_col + label_width * 2 < first_char and first_char > 1 then
                    ok2, mark_id2 = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1,
                        first_char - label_width, {
                            virt_text = { { tostring(rel), "Sub" } },
                            virt_text_pos = "overlay"
                        })
                    if ok2 then
                        table.insert(extmarks, mark_id2)
                    end
                end

                -- auxline from line_start to first_char
                -- print(cursor_col, first_char)
                if cursor_col <= first_char then
                    -- vim.notify("TEST")
                    for col = cursor_col + label_width, first_char - 1 - label_width do
                        ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1,
                            col, {
                                virt_text = { { config.peep.auxline_icon, "aux" } },
                                virt_text_pos = "overlay"
                            })
                        if ok3 then
                            table.insert(extmarks, mark_id3)
                        end
                    end
                end
                -- if first_char + label_width < last_char - label_width then
                --     ok4, mark_id4 = pcall(vim.api.nvim_buf_set_extmark, bufnr, state.extmark_ns, row - 1,
                --         math.floor((first_char + last_char) / 2), {
                --             virt_text = { { tostring(rel), "subPeep_hl" } },
                --             virt_text_pos = "overlay"
                --         })
                --     if ok3 then table.insert(extmarks, mark_id4)
                --     end
                -- end
            end
        else
            if config.peep.column then
                local start_col = 0
                local end_col = cur_line_width

                for col = start_col, end_col do
                    local rel = math.abs(col - cursor_col)
                    if rel % 10 == 0 then
                        local ok, mark_id

                        ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, state.src_buf, extmark_ns, row - 1, col,
                            {
                                virt_text = { { tostring(rel), "Main" } },
                                virt_text_pos = "overlay"
                            })
                        if ok then
                            table.insert(extmarks, mark_id)
                        end
                    end
                end
            end
        end
    end
end

local function reset_state()
    state.src_buf = nil
    state.src_win = nil
end

function M.clear()
    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, state.src_buf, extmark_ns, id)
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

function M.peep()
    -- if state.is_showing then
    --     return
    -- end
    --
    -- state.is_showing = true

    M.show()

    local timer = vim.loop.new_timer()
    timer:start(config.peep.duration, 0, vim.schedule_wrap(function()
        M.clear()
        timer:stop()
        timer:close()
    end))
end

function M.close()
    state.is_showing = false
    return M.clear()
end

function M.open()
    state.is_showing = true
    M.show()
end

return M
