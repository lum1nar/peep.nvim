local M = {}

local core = require("peep.core")
local utils = require("peep.utils")
local config = require("peep.config")

M.state = {
    peep_buf = nil,
    peep_win = nil,
    is_showing = false,
    was_visual = nil
}

M.setup = function(opts)
    opts = opts or {}

    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)
end

M.peep = function()
    core.peep(config, M.state)
end

return M
