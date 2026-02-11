local M = {}

local config = require("peep.config")
local state = require("peep.state")
local ui = require("peep.ui")

---@param opts table|nil
function M.setup(opts)
    opts = opts or {}

    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)

    if config.peep.key_trigger then
        for idx, key in ipairs(config.peep.trigger_keys) do
            vim.keymap.set("n", key, function()
                vim.schedule(function()
                    M.open()
                end)

                state.in_op = true
                return key
            end, { expr = true, silent = true })
        end
    end
end

function M.open()
    if state.is_showing then return end
    state.is_showing = true
    ui.show()
end

function M.close()
    if not state.is_showing then return end
    state.is_showing = false
    ui.clear()
end

function M.peep()
    ui.show()

    local timer = vim.loop.new_timer()
    timer:start(config.peep.duration, 0, vim.schedule_wrap(function()
        ui.clear()
        timer:stop()
        timer:close()
    end))
end

return M
