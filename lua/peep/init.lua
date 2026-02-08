local M = {}

local core = require("peep.core")
local utils = require("peep.utils")
local config = require("peep.config")

M.state = {
    src_buf = nil,
    src_win = nil,
    peep_buf = nil,
    peep_win = nil,
    is_showing = false,
    was_visual = false,
    topline = nil,
    botline = nil,
    last_buf = nil,
    keylog = {},
}

M.setup = function(opts)
    opts = opts or {}

    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)

    if config.peep.key_trigger then
        for idx, key in ipairs(config.peep.trigger_keys) do
            vim.keymap.set("n", key, function()
                utils.log(M.state, key)
                vim.schedule(function()
                    core.toggle(config, M.state)
                end)
                return ""
            end, { expr = false, silent = true })
        end
    end
end

M.peep = function()
    core.peep(config, M.state, config.peep.duration)
end

M.toggle = function()
    core.toggle(config, M.state)
end

return M
