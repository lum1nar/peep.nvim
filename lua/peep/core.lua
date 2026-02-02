local M = {}
local ns_id = vim.api.nvim_create_namespace("Peep_ns")
local extmarks = {}

function M.show(config)
    vim.api.nvim_set_hl(0, "Peep_hl", { fg = config.fg_color, bg = config.bg_color, bold = true })
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row, cursor_col = cursor[1], cursor[2]

    -- In case someone triggers more than once during timer
    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_id, id)
    end
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
            local draw_col = cursor_col
            -- print(cur_line_width)
            local ok, mark_id

            if draw_col < 5 then
                draw_col = 40
            end

            if cur_line_width < draw_col then
                ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, cur_line_width, {
                    virt_text = { { tostring(rel), "Peep_hl" } },
                    virt_text_pos = "overlay"
                })
            else
                ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, draw_col, {
                    virt_text = { { tostring(rel), "Peep_hl" } },
                    virt_text_pos = "overlay"
                })
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

function M.clear()
    local bufnr = vim.api.nvim_get_current_buf()
    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, bufnr, ns_id, id)
    end
    extmarks = {}
end

function M.peep(config)
    M.show(config)
    local timer = vim.loop.new_timer()
    timer:start(config.peep_duration, 0, vim.schedule_wrap(function()
        M.clear()
        timer:stop()
        timer:close()
    end))
end

return M
