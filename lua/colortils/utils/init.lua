local utils = {}

---@diagnostic disable-next-line: unused-local
local log = require("colortils.log")

--- Get the hex code of a number (two digits)
---@param number number
---@return string
function utils.hex(number)
    number = math.max(math.min(number, 255), 0)
    return string.format("%02X", number)
end

--- Rounds a float
---@param number float
---@return number rounded
function utils.round_float(number)
    if number - math.floor(number) < 0.5 then
        return math.floor(number)
    else
        return math.ceil(number)
    end
end

--- Adjust a color value (with maximum and minimum)
---@param value number
---@param amount number
---@return number adjusted
function utils.adjust_value(value, amount)
    value = value + amount
    return math.max(math.min(value, 255), 0)
end

--- Gets a partial block for a number between 0 and 1
---@param number number
---@return string
function utils.get_partial_block(number)
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
function utils.get_bar(value, max_value, max_width)
    -- get value of one block
    local block_value = max_value / max_width
    -- get amount of full blocks
    local bar = string.rep("█", math.floor(value / block_value))
    return bar .. utils.get_partial_block(value / block_value - math.floor(value / block_value))
end

--- Checks if is valid color
---@param color string Hex color code
function utils.validate_color_complete(color)
    if color:match("^#%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end

--- Checks if is valid color
---@param color string Hex color code without #
function utils.validate_color_numbers(color)
    if color:match("^%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end

-- TODO: make this custom for better errors
--- Validates settings
---@param settings table
function utils.validate_settings(settings)
    vim.validate({
        register = {
            settings.register,
            function(reg)
                if reg:gmatch("%w") then
                    return true
                elseif vim.tbl_contains({ "-", "#", "=", "+", "_", " ", "/", "" }, reg) then
                    return true
                else
                    return false
                end
            end,
            "vim register",
        },
        color_preview = { settings.color_preview, "string" },
        border = {
            settings.border,
            function(bord)
                if
                    vim.tbl_contains({
                        "rounded",
                        "single",
                        "double",
                        "solid",
                        "shadow",
                        "none",
                    }, bord)
                then
                    return true
                end
                if type(bord) == "table" and vim.tbl_contains({ 1, 2, 4, 8 }, #bord) then
                    return true
                end
            end,
            "none|single|double|rounded|solid|shadow|array",
        },
    })
end

return utils
