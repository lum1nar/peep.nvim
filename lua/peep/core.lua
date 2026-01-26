local M = {}
local ns_id = vim.api.nvim_create_namespace("ColRelativeNumbers")
local extmarks = {}

function M.show(config)
    vim.api.nvim_set_hl(0, "ColRelNum", { fg = config.fg_color, bg = config.bg_color, bold = true })
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
        if row ~= cursor_row then
            local rel = math.abs(row - cursor_row)
            local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
            local line = lines[1] or "" -- 避免 nil
            local cur_line_width = #line
            -- print(cur_line_width)
            local ok, mark_id
            if cur_line_width < cursor_col then
                ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, cur_line_width, {
                    virt_text = { { tostring(rel), "ColRelNum" } },
                    virt_text_pos = "overlay"
                })
            else
                ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, cursor_col, {
                    virt_text = { { tostring(rel), "ColRelNum" } },
                    virt_text_pos = "overlay"
                })
            end
            if ok then
                table.insert(extmarks, mark_id)
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
