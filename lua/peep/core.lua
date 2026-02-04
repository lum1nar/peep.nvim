local utils = require("peep.utils")

local M = {}
local ns_id = vim.api.nvim_create_namespace("Peep_ns")
local extmarks = {}

function M.show(config, state)
    -- show
    utils.win_open(state)
    vim.api.nvim_set_hl(0, "Peep_hl", { fg = config.fg_color, bg = config.bg_color, bold = true })
    vim.api.nvim_set_hl(0, "subPeep_hl", { fg = "#f6c177", bg = "#44415a", bold = true })
    vim.api.nvim_set_hl(0, "aux", { fg = "#797593", bold = true })
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row, cursor_col = cursor[1], cursor[2]

    extmarks = {}

    local win_height = vim.api.nvim_win_get_height(0)
    -- print(win_height)
    local start_row = math.max(1, cursor_row - win_height)
    local end_row = cursor_row + win_height

    for row = start_row, end_row do
        local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
        local line = lines[1] or "" -- avoid nil
        local cur_line_width = #line
        if row ~= cursor_row then
            local rel = math.abs(row - cursor_row)
            -- print(cur_line_width)
            local ok, ok2, ok3, mark_id, mark_id2, mark_id3
            --- search for the last non-space char
            -- print(row, #line)
            local last_char = line:find("%s*$") - 1
            -- vim.notify(tostring(last_char))
            -- print(last_char)

            ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, cursor_col, {
                virt_text = { { tostring(rel), "Peep_hl" } },
                virt_text_pos = "overlay"
            })

            if last_char > 1 and last_char < cursor_col then
                ok2, mark_id2 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, last_char, {
                    virt_text = { { tostring(rel), "subPeep_hl" } },
                    virt_text_pos = "overlay"
                })
                if ok2 then
                    table.insert(extmarks, mark_id2)
                end

                local offset = 1

                if rel >= 10 then
                    offset = 2
                elseif rel >= 100 then
                    offset = 3
                end

                for col = last_char + offset, cursor_col - 1 do
                    ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, col, {
                        virt_text = { { '.', "aux" } },
                        virt_text_pos = "overlay"
                    })
                    if ok3 then
                        table.insert(extmarks, mark_id3)
                    end
                end
            end

            if ok then
                table.insert(extmarks, mark_id)
            end
        else
            if config.col_peep then
                local start_col = 0
                local end_col = cur_line_width

                for col = start_col, end_col do
                    local rel = math.abs(col - cursor_col)
                    if rel % 10 == 0 then
                        local ok, mark_id

                        ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, col, {
                            virt_text = { { tostring(rel), "Peep_hl" } },
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

function M.clear(state)
    local bufnr = vim.api.nvim_get_current_buf()
    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_id, id)
    end
    extmarks = {}
    utils.win_close(state)
end

function M.peep(config, state)
    if state.is_showing then
        return
    end

    M.show(config, state)
    local timer = vim.loop.new_timer()
    timer:start(config.peep_duration, 0, vim.schedule_wrap(function()
        M.clear(state)
        timer:stop()
        timer:close()
    end))
end

return M
