local M = {}

M.state = {
    src_buf = nil,
    src_win = nil,
    peep_buf = nil,
    peep_win = nil,
    is_showing = false,
    was_visual = false,
    in_op = false,
    topline = 0,
    botline = 0,
    last_buf = nil,
    keylog = {},
    cursor_row = 0,
    cursor_col = 0,
    win_height = 0,
    extmark_ns = 0,
    key_ns = nil

}

return M
