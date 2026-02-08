local utils = require("peep.utils")
local M = {}
local ns_id = vim.api.nvim_create_namespace("Peep_ns")
local extmarks = {}
function M.show(config, state) -- show
    utils.win_open(state)
    vim.api.nvim_set_hl(0, "Main", { fg = config.colors.label_main.fg, bg = config.colors.label_main.bg, bold = true })
    vim.api.nvim_set_hl(0, "Sub", { fg = config.colors.label_sub.fg, bg = config.colors.label_sub.bg, bold = true })
    vim.api.nvim_set_hl(0, "Aux", { fg = config.colors.line_aux.fg, bold = true })
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(state.peep_win)
    local cursor_row, cursor_col = cursor[1], cursor[2]

    -- deal with unexpected close(:q, etc)
    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function()
            M.clear(state)
        end,
    })

    extmarks = {}

    local win_height = vim.api.nvim_win_get_height(0)
    -- vim.notify(tostring(win_height))
    -- print(win_height) local start_row = 1 local end_row = win_height
    -- print(start_row, end_row, cursor_row) local start_row = 1
    local start_row = 1
    local end_row = win_height
    for row = start_row, end_row do
        local lines = vim.api.nvim_buf_get_lines(state.peep_buf, row - 1, row, false)
        local line = lines[1] or "" -- avoid nil
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
            ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, cursor_col, {
                virt_text = { { tostring(rel), "Main" } },
                virt_text_pos = "overlay"
            })

            if ok then
                table.insert(extmarks, mark_id)
            end

            -- line end label
            if last_char > 1 and last_char + label_width < cursor_col then
                ok2, mark_id2 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, last_char, {
                    virt_text = { { tostring(rel), "Sub" } },
                    virt_text_pos = "overlay"
                })
                if ok2 then
                    table.insert(extmarks, mark_id2)
                end

                -- auxline from last char to cursor_col
                if cursor_col >= last_char then
                    for col = last_char + label_width, cursor_col - 1 do
                        ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, col, {
                            virt_text = { { config.peep.auxline_icon, "aux" } },
                            virt_text_pos = "overlay"
                        })
                        if ok3 then
                            table.insert(extmarks, mark_id3)
                        end
                    end
                end
            else
                if cursor_col + label_width < first_char and first_char > 1 then
                    ok2, mark_id2 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1,
                        first_char - label_width, {
                            virt_text = { { tostring(rel), "Sub" } },
                            virt_text_pos = "overlay"
                        })
                end

                if ok then
                    if ok2 then
                        table.insert(extmarks, mark_id2)
                    end
                    -- auxline from line_start to first_char
                    -- print(cursor_col, first_char)
                    if cursor_col <= first_char then
                        -- vim.notify("TEST")
                        for col = cursor_col + label_width, first_char - 1 - label_width do
                            ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, col, {
                                virt_text = { { config.peep.auxline_icon, "aux" } },
                                virt_text_pos = "overlay"
                            })
                            if ok3 then
                                table.insert(extmarks, mark_id3)
                            end
                        end
                    end
                end
                -- if first_char + label_width < last_char - label_width then
                --     ok4, mark_id4 = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1,
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

                        ok, mark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, row - 1, col, {
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

function M.finish(state)
    if state.is_showing == false or state.peep_win == nil or state.src_buf == nil then
        return
    end

    -- print("finishing")

    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, state.peep_buf, ns_id, id)
    end
    extmarks = {}
    utils.win_close(state)

    -- simulate key presses
    if next(state.keylog) ~= nil then
        for _, key in ipairs(state.keylog) do
            -- if type(key) ~= "string" then
            --     print("INVALID KEYLOG:", _, vim.inspect(key), type(key))
            -- end
            -- print(key)
            local k = vim.api.nvim_replace_termcodes(tostring(key), true, false, true)
            vim.api.nvim_feedkeys(k, "n", false)
        end
    end

    -- reset state
    state.peep_win = nil
    state.peep_buf = nil
    state.was_visual = false
    state.src_buf = nil
    state.src_win = nil
    state.topline = nil
    state.botline = nil
    state.last_buf = nil
    state.keylog = {}
end

function M.clear(state)
    if state.is_showing == false or state.peep_win == nil or state.src_buf == nil then
        return
    end

    -- print("cleaning")

    for _, id in ipairs(extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, state.peep_buf, ns_id, id)
    end
    extmarks = {}

    utils.win_close(state)

    -- reset state
    state.peep_win = nil
    state.peep_buf = nil
    state.was_visual = false
    state.src_buf = nil
    state.src_win = nil
    state.topline = nil
    state.botline = nil
    state.last_buf = nil
    state.keylog = {}
end

function M.peep(config, state, duration)
    if state.is_showing then
        return
    end

    state.is_showing = true

    M.show(config, state)

    local timer = vim.loop.new_timer()
    timer:start(duration, 0, vim.schedule_wrap(function()
        M.clear(state)
        timer:stop()
        timer:close()
    end))
end

function M.toggle(config, state)
    if state.is_showing then
        -- vim.notify("clear")
        return M.clear(state)
    end

    state.is_showing = true
    M.show(config, state)

    local finish_keys = {
        -- basic movement
        "h", "j", "k", "l",

        -- word motions
        "w", "W",
        "b", "B",
        "e", "E",

        -- line motions
        "0", "^", "$", "_",

        -- line / operator
        "d",
        "y",
        "c",

        -- paragraph / sentence
        "{", "}",
        "(", ")",

        -- structure
        "%",

        -- search repeat
        "n", "N",
    }
    local passthrough_keys = {
        -- ===============================
        -- Text objects
        -- ===============================
        "a", "i",

        -- ===============================
        -- Char-pending motions
        -- ===============================
        "f", "F", "t", "T",

        -- ===============================
        -- Search motions
        -- ===============================
        "/", "?", "*", "#", "g*", "g#",
        "n", "N",

        -- ===============================
        -- Marks / jumps
        -- ===============================
        "'", "`",
        "G", "gg", "H", "M", "L",
        "%", "(", ")", "{", "}",
        "[[", "]]", "[]", "][",

        -- ===============================
        -- Command / Ex
        -- ===============================
        ":",

        -- ===============================
        -- Repeat last f/t
        -- ===============================
        ";", ",",

        -- ===============================
        -- Register / macros
        -- ===============================
        '"', "q", "@",

        -- ===============================
        -- Operators / formatting
        -- ===============================
        "d", "y", "c", ">", "<", "=", "g", "z",

        -- ===============================
        -- Ctrl motions (scroll / jump)
        -- ===============================
        "<C-d>", "<C-u>", "<C-f>", "<C-b>", "<C-o>", "<C-i>",

        -- ===============================
        -- Misc / plugin hooks
        -- ===============================
        "[", "]",
    }

    local escape_keys = {
        -- mode control
        "<Esc>",
        "<C-c>",
        "<C-[>",

        -- command-line / search
        ":", -- command mode
        "/", -- search forward
        "?", -- search backward

        -- visual / select
        "v",
        "V",
        "<C-v>",

        -- window / buffer control
        "<C-w>",

        -- undo / redo
        "u",
        "<C-r>",

        -- macros / registers
        "q",
        "@",

        -- replace / change line
        "R",

        -- completion / special
        "<Tab>",
        "<S-Tab>",
        "<CR>",

        -- mouse
        "<LeftMouse>",
        "<RightMouse>",
        "<MiddleMouse>",
    }

    -- finish key
    for _, k in ipairs(finish_keys) do
        vim.keymap.set("n", k, function()
            utils.log(state, tostring(k))
            return M.finish(state)
        end, {
            buffer = state.peep_buf,
            expr = false,
            nowait = true,
            silent = true,
        })
    end

    -- repeat key
    local repeat_value = 0
    for key = 0, 9 do
        vim.keymap.set({ "n", "v" }, tostring(key), function()
            -- vim.notify(tostring(config.peep.line_preview))
            if config.peep.line_preview then
                repeat_value = repeat_value * 10 + key

                local cursor_row = vim.api.nvim_win_get_cursor(state.peep_win)[1] - 1
                -- local cursor_col = vim.api.nvim_win_get_cursor(state.peep_win)[2]
                local ns_range = vim.api.nvim_create_namespace("range")

                vim.api.nvim_set_hl(0, "range", { bg = config.colors.line_preview.bg })
                vim.api.nvim_set_hl(0, "cursor_row", { bg = "#dfdad9" })

                local win_height = vim.api.nvim_win_get_height(0)

                -- remove extmark within selection range
                vim.api.nvim_buf_clear_namespace(state.peep_buf, ns_id, math.max(0, cursor_row - repeat_value),
                    math.min(win_height, cursor_row + repeat_value + 1))

                -- vim.api.nvim_buf_add_highlight(state.peep_buf, ns_range, "cursor_row", cursor_row, 0, -1)

                -- color selection range
                for i = 1, repeat_value do
                    vim.api.nvim_buf_add_highlight(state.peep_buf, ns_range, "range",
                        math.min(cursor_row + i, win_height), 0,
                        -1)
                    vim.api.nvim_buf_add_highlight(state.peep_buf, ns_range, "range", math.max(0, cursor_row - i), 0, -1)
                end

                -- Tried to give some hint on navigation but not ideal
                -- local ok3, mark_id3
                -- ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, state.peep_buf, ns_id, cursor_row + repeat_value,
                --     cursor_col, {
                --         virt_text = { { "j", "range" } },
                --         virt_text_pos = "overlay"
                --     })
                -- if ok3 then
                --     table.insert(extmarks, mark_id3)
                -- end
                --
                -- ok3, mark_id3 = pcall(vim.api.nvim_buf_set_extmark, state.peep_buf, ns_id, cursor_row - repeat_value,
                --     cursor_col, {
                --         virt_text = { { "k", "Main" } },
                --         virt_text_pos = "overlay"
                --     })
                -- if ok3 then
                --     table.insert(extmarks, mark_id3)
                -- end

                -- vim.notify(tostring(repeat_value))
            end

            utils.log(state, key)

            return ""
        end, {
            buffer = state.peep_buf,
            expr = false,
            nowait = true,
            silent = true,
        })
    end

    -- passthrough_keys
    for _, k in ipairs(passthrough_keys) do
        vim.keymap.set({ "n", "v" }, k, function()
            utils.log(state, tostring(k))
            return M.finish(state)
        end, {
            buffer = state.peep_buf,
            expr = false,
            nowait = true,
            silent = true,
        })
    end

    -- escape_keys
    for _, k in ipairs(escape_keys) do
        vim.keymap.set({ "n", "v" }, k, function()
            return M.clear(state)
        end, {
            buffer = state.peep_buf,
            expr = false,
            nowait = true,
            silent = true,
        })
    end

    -- leader key
    vim.keymap.set({ "n", "v" }, "<leader>", function()
        utils.log(state, tostring("<leader>"))
        return M.finish(state)
    end, {
        buffer = state.peep_buf,
        expr = false,
        nowait = true,
        silent = true,
    })
end

return M
