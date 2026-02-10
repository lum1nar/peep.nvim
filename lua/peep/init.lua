local M = {}

local config = require("peep.config")
local state = require("peep.state")
local peep = require("peep.peep")

M.setup = function(opts)
    opts = opts or {}

    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)

    if config.peep.key_trigger then
        for idx, key in ipairs(config.peep.trigger_keys) do
            vim.keymap.set("n", key, function()
                -- if M.state.in_operator then
                --     return
                -- end
                vim.schedule(function()
                    peep.open()
                end)

                state.in_op = true
                -- M.state.operator = key
                return key
            end, { expr = true, silent = true })
        end
    end
end

M.peep = function()
    peep.peep()
end

return M
