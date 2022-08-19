local tool_utils = {}
---@alias Tool "Picker"|"Gradient"|"Greyscale"|"Lighten"|"Darken"

local utils = require("colortils.utils")
local color_utils = require("colortils.utils.colors")

function tool_utils.get_color(color)
    color = color or ""
    local color_table = color_utils.get_colors(color)
    if color_table and color_table ~= {} and #color_table == 1 then
        return color_table[1]
    end
    color = vim.fn.input("Input a color > ", "")
    color_table = tool_utils.get_color(color)
    return color_table
end

local tools = {
    ["Picker"] = function(hex_color, alpha)
        require("colortils.tools.picker")(hex_color, alpha)
    end,
    ["Gradient"] = function(hex_color, alpha)
        local color_2 = tool_utils.get_color()
        local hex_color_2 = "#"
            .. utils.hex(color_2.rgb_values[1])
            .. utils.hex(color_2.rgb_values[2])
            .. utils.hex(color_2.rgb_values[3])
        require("colortils.tools.gradients.colors")(hex_color, hex_color_2, alpha)
    end,
    ["Greyscale"] = function(hex_color, alpha)
        require("colortils.tools.gradients.greyscale")(hex_color, alpha)
    end,
    ["Lighten"] = function(hex_color, alpha)
        require("colortils.tools.lighten")(hex_color, alpha)
    end,
    ["Darken"] = function(hex_color, alpha)
        require("colortils.tools.darken")(hex_color, alpha)
    end,
}

--- Export a color to a different tool
---@param tool Tool
---@param color string #RRGGBB
---@param transparency integer|nil
function tool_utils.export(tool, color, transparency)
    tools[tool](color, transparency and (1 - transparency / 100))
end

return tool_utils
