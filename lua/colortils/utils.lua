local utils = {}

local log = require("colortils.log")

--- Get the hex code of a number (two digits)
---@param number number
---@return string
utils.hex = function(number)
    return string.format("%02X", number)
end

--- Gets a partial block for a number between 0 and 1
---@param number number
---@return string
utils.get_partial_block = function(number)
    if number >= 0.875 then
        return "▉"
    elseif number >= 0.75 then
        return "▊"
    elseif number >= 0.625 then
        return "▋"
    elseif number >= 0.5 then
        return "▌"
    elseif number >= 0.375 then
        return "▍"
    elseif number >= 0.25 then
        return "▎"
    elseif number >= 0.125 then
        return "▏"
    else
        return ""
    end
end

--- Produces a progress bar
---@param value number
---@param max_value number Maximum possible value
---@param max_width number Maximum possible width of the bar (value==max_value)
---@return string Bar
utils.get_bar = function(value, max_value, max_width)
    -- get value of one block
    local block_value = max_value / max_width
    -- get amount of full blocks
    local bar = string.rep("█", math.floor(value / block_value))
    return bar
        .. utils.get_partial_block(
            value / block_value - math.floor(value / block_value)
        )
end

--- Checks if is valid color
---@param color string Hex color code
utils.validate_color_complete = function(color)
    if color:match("^#%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end

--- Checks if is valid color
---@param color string Hex color code without #
utils.validate_color_numbers = function(color)
    if color:match("^%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end

return utils
