local utils_color = {}

local utils = require("colortils.utils")
local log = require("colortils.log")

--- Gets the values of a hex color
---@param color string "#xxxxxx"
---@return number, number, number "red,green,blue"
function utils_color.get_values(color)
    local red = tonumber(color:sub(2, 3), 16)
    local green = tonumber(color:sub(4, 5), 16)
    local blue = tonumber(color:sub(6, 7), 16)
    return red, green, blue
end

--- Get colors for a gradient
---@param start_color string "#xxxxxx"
---@param end_color string "#xxxxxx"
---@param total_length number
---@return table colors
function utils_color.gradient_colors(start_color, end_color, total_length)
    local points = total_length - 2
    if points < 0 then
        points = 0
    end
    local start_red, start_green, start_blue = utils_color.get_values(start_color)
    if not start_red then
        return
    end
    local end_red, end_green, end_blue = utils_color.get_values(end_color)
    if not end_red then
        return
    end
    local red_step = (end_red - start_red) / (points + 1)
    local green_step = (end_green - start_green) / (points + 1)
    local blue_step = (end_blue - start_blue) / (points + 1)
    local gradient_colors = {
        "#" .. utils.hex(start_red) .. utils.hex(start_green) .. utils.hex(start_blue),
    }
    for i = 1, points do
        gradient_colors[#gradient_colors + 1] = "#"
            .. utils.hex(utils.round_float(start_red + red_step * i))
            .. utils.hex(utils.round_float(start_green + green_step * i))
            .. utils.hex(utils.round_float(start_blue + blue_step * i))
    end
    gradient_colors[#gradient_colors + 1] = "#" .. utils.hex(end_red) .. utils.hex(end_green) .. utils.hex(end_blue)

    return gradient_colors
end

---@param alpha number 0-1
function utils_color.get_blended_gradient(start_color, end_color, length, alpha, background)
    local blended_gradient = {}
    local gradient = utils_color.gradient_colors(start_color, end_color, length)
    if not (alpha and background) then
        return gradient
    end
    for _, color in ipairs(gradient) do
        blended_gradient[#blended_gradient + 1] = utils_color.blend_colors(color, background, alpha)
    end
    return blended_gradient
end

utils_color.display_gradient =
    --- Displays gradient at a certain position
    ---@param buf number
    ---@param ns number
    ---@param line number
    ---@param start_color string "#xxxxxx"
    ---@param end_color string "#xxxxxx"
    ---@param width number
    ---@param alpha
    function(buf, ns, line, start_color, end_color, width, alpha, background)
        width = width * 2
        local gradient
        if alpha then
            gradient = utils_color.get_blended_gradient(
                start_color,
                end_color,
                width,
                alpha,
                background or vim.fn.input("Background >")
            )
        else
            gradient = utils_color.gradient_colors(start_color, end_color, width)
        end
        vim.api.nvim_buf_set_lines(buf, line, line, false, { string.rep("▌", width / 2) })
        for i = 1, width do
            vim.api.nvim_set_hl(0, "ColortilsGradient" .. i, { fg = gradient[2 * i], bg = gradient[2 * i + 1] })
        end
        for i = 1, width do
            vim.api.nvim_buf_add_highlight(buf, ns, "ColortilsGradient" .. i, line, 3 * i - 1, 3 * i)
        end
    end

--- Gets the gray color for a certain color
---@param color string "#xxxxxx"
---@return string color
function utils_color.get_grey(color)
    local red, green, blue = utils_color.get_values(color)
    local amount = red * 0.2126 + green * 0.7152 + blue * 0.0722
    local single_hex = utils.hex(utils.round_float(amount))
    return "#" .. string.rep(single_hex, 3)
end

--- Gets complementary color
---@param color string "#xxxxxx"
---@return string color
function utils_color.complementary(color)
    local red, green, blue = utils_color.get_values(color)
    red = utils.hex(255 - red)
    green = utils.hex(255 - green)
    blue = utils.hex(255 - blue)
    return "#" .. red .. green .. blue
end

-- functions from https://github.com/NTBBloodbath/color-converter.nvim
--- Converts rgb to hsl
---@param r number
---@param g number
---@param b number
---@param a float
---@return table
function utils_color.rgb_to_hsl(r, g, b, a)
    r = r / 255
    g = g / 255
    b = b / 255
    a = a and a or 0

    local c_max = math.max(r, g, b)
    local c_min = math.min(r, g, b)
    local h = 0
    local s = 0
    local l = (c_min + c_max) / 2

    local chroma = c_max - c_min
    if chroma > 0 then
        s = math.min((l <= 0.5 and chroma / (2 * l) or chroma / (2 - (2 * l))), 1)

        if c_max == r then
            h = ((g - b) / chroma + (g < b and 6 or 0))
        elseif c_max == g then
            h = (b - r) / chroma + 2
        elseif c_max == b then
            h = (r - g) / chroma + 4
        end

        h = h * 60
        h = math.floor(h + 0.5)
    end

    return {
        h,
        ("%.1f"):format(s * 100),
        ("%.1f"):format(l * 100),
        a,
    }
end

--- Converts hue to rgb
---@param p number
---@param q number
---@param t number
---@return number
local function hue_to_rgb(p, q, t)
    if t < 0 then
        t = t + 1
    end
    if t > 1 then
        t = t - 1
    end
    if t < 1 / 6 then
        return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
        return q
    end
    if t < 2 / 3 then
        return p + (q - p) * (2 / 3 - t) * 6
    end

    return p
end

--- Converts hsl to rgb
---@param h number
---@param s number
---@param l number
---@param a number alpha (1-100)
---@return table
function utils_color.hsl_to_rgb(h, s, l, a)
    h = h / 360
    s = s / 100
    l = l / 100
    local r, g, b

    -- achromatic
    if s == 0 then
        r = l
        g = l
        b = l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue_to_rgb(p, q, h + 1 / 3)
        g = hue_to_rgb(p, q, h)
        b = hue_to_rgb(p, q, h - 1 / 3)
    end

    return {
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5),
        a,
    }
end

--- Gets red, green and blue values for color
---@param color string @#RRGGBB
---@return string[]
function utils_color.get_color_values(color)
    local red = tonumber(color:sub(2, 3), 16)
    local green = tonumber(color:sub(4, 5), 16)
    local blue = tonumber(color:sub(6, 7), 16)
    return { red, green, blue }
end

--- Blends top color over bottom color
---@param top string @#RRGGBB
---@param bottom string @#RRGGBB
---@param alpha float
function utils_color.blend_colors(top, bottom, alpha)
    local top_rgb = utils_color.get_color_values(top)
    local bottom_rgb = utils_color.get_color_values(bottom)
    local function blend(c)
        c = (alpha * top_rgb[c] + ((1 - alpha) * bottom_rgb[c]))
        return math.floor(math.min(math.max(0, c), 255) + 0.5)
    end
    return ("#%02X%02X%02X"):format(blend(1), blend(2), blend(3))
end

function utils_color.get_colors(color_string)
    local patterns = {
        {
            colors = function(match)
                return utils_color.get_color_values(match)
            end,
            transparency = false,
            name = "hex",
            pattern = "#%x%x%x%x%x%x",
        },
        {
            colors = function(match)
                local red = tonumber(match:sub(2, 3), 16)
                local green = tonumber(match:sub(4, 5), 16)
                local blue = tonumber(match:sub(6, 7), 16)
                local alpha = tonumber(match:sub(8, 9), 16)
                return { red, green, blue, alpha }
            end,
            transparency = true,
            name = "hex alpha",
            pattern = "#%x%x%x%x%x%x%x%x",
        },
        {
            colors = function(match)
                local values = {
                    match:match("rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)"),
                }
                return {
                    tonumber(values[1]),
                    tonumber(values[2]),
                    tonumber(values[3]),
                }
            end,
            transparency = false,
            name = "rgb",
            pattern = "rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)",
        },
        {
            colors = function(match)
                local values = {
                    match:match("rgba%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+%.?%d*)%s*%)"),
                }
                return {
                    tonumber(values[1]),
                    tonumber(values[2]),
                    tonumber(values[3]),
                    tonumber(values[4]),
                }
            end,
            transparency = true,
            name = "rgba",
            pattern = "rgba%(%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%.?%d*%s*%)",
        },
        {
            colors = function(match)
                local values = {
                    match:match("rgb%(%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)"),
                }
                return {
                    tonumber(values[1]) / 100 * 255,
                    tonumber(values[2]) / 100 * 255,
                    tonumber(values[3]) / 100 * 255,
                }
            end,
            transparency = false,
            name = "rgb percentage",
            pattern = "rgb%(%d+%%%s*,%s*%d+%%%s*,%s*%d+%%%s*%)",
        },
        {
            colors = function(match)
                local values = {
                    match:match("rgba%((%d+)%%%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*(%d+%.?%d?)%s*%)"),
                }
                return {
                    tonumber(values[1]) / 100 * 255,
                    tonumber(values[2]) / 100 * 255,
                    tonumber(values[3]) / 100 * 255,
                }
            end,
            transparency = true,
            name = "rgba percentage",
            pattern = "rgba%(%d+%%%s*,%s*%d+%%%s*,%s*%d+%%%s*,%s*%d+%.?%d*%s*%)",
        },
        {
            colors = function(match)
                local values = {
                    match:match("hsl%((%d+%.?%d?)%s*,%s*(%d+%.?%d?)%%%s*,%s*(%d+%.?%d?)%%%s*%)"),
                }
                local rgb = utils_color.hsl_to_rgb(values[1], values[2], values[3])
                return { rgb[1], rgb[2], rgb[3] }
            end,
            transparency = false,
            name = "hsl",
            pattern = "hsl%(%d+%.?%d?%s*,%s*%d+%.?%d?%%%s*,%s*%d+%.?%d?%%%s*%)",
        },
        {
            colors = function(match)
                local values = {
                    match:match("hsla%((%d+%.?%d?)%s*,%s*(%d+%.?%d?)%%%s*,%s*(%d+%.?%d?)%%%s*,%s*(%d+%.?%d?)%s*%)"),
                }
                local rgb = utils_color.hsl_to_rgb(values[1], values[2], values[3], values[4])
                return { rgb[1], rgb[2], rgb[3], rgb[4] }
            end,
            transparency = true,
            name = "hsla",
            pattern = "hsla%(%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*,%s*%d+%.?%d*%s*%)",
        },
    }
    local colors = {}
    local match
    for _, color_format in ipairs(patterns) do
        local start = 1
        while true do
            local start_pos, end_pos = color_string:find(color_format.pattern, start)
            if start_pos == nil then
                break
            end
            match = color_string:match(color_format.pattern, start)
            table.insert(colors, {
                start_pos = start_pos,
                end_pos = end_pos,
                match = match,
                rgb_values = color_format.colors(match),
                type = color_format.name,
                transparency = color_format.transparency,
            })
            start = end_pos + 1
        end
    end
    return colors
end

function utils_color.get_color_under_cursor(winnr)
    local buf = vim.fn.winbufnr(winnr)
    local cursor = vim.api.nvim_win_get_cursor(winnr)
    local pos = cursor[2] + 1
    local colors = utils_color.get_colors(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[cursor[1]])
    local color_table
    for _, color in ipairs(colors) do
        if pos >= color.start_pos and pos <= color.end_pos then
            color_table = color
            break
        end
    end
    return color_table or nil
end

function utils_color.replace_under_cursor(replacement, window)
    window = window or 0
    local cursor = vim.api.nvim_win_get_cursor(window)
    local color_table = utils_color.get_color_under_cursor(window)
    if not color_table then
        log.warn("No color found under cursor")
        return
    end
    vim.api.nvim_buf_set_text(
        0,
        cursor[1] - 1,
        color_table.start_pos - 1,
        cursor[1] - 1,
        color_table.end_pos,
        { replacement }
    )
end

return utils_color
