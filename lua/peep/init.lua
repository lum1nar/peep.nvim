local M = {}
local core = require("peep.core")
local config = require("peep.config")

M.setup = function(opts)
    opts = opts or {}

    -- merge table
    -- force mode, if one key has multiple values, the one from
    -- the rightmost table will be chosen
    config = vim.tbl_deep_extend("force", config, opts)
end

M.peep = function()
    core.peep(config);
end
return M
