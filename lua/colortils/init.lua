local colortils = {}

local settings = {
    register = "+",
    ---String: "block"|"hex"
    color_display = "block",
}

local utils = require("colortils.utils")

local red = 0
local green = 0
local blue = 0
local buf = nil
local win = nil
local ns = vim.api.nvim_create_namespace("ColorPicker")

colortils.setup = function(update)
    settings = vim.tbl_deep_extend("force", settings, update or {})
end

return colortils
