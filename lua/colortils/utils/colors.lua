local utils_color = {}

local utils = require("colortils.utils")

utils_color.get_values = function(color)
    local red, green, blue
    if color and utils.validate_color_numbers(color) then
        red = tonumber(color:sub(1, 2), 16)
        green = tonumber(color:sub(3, 4), 16)
        blue = tonumber(color:sub(5, 6), 16)
        return red, green, blue
    elseif color and utils.validate_color_complete(color) then
        red = tonumber(color:sub(2, 3), 16)
        green = tonumber(color:sub(4, 5), 16)
        blue = tonumber(color:sub(6, 7), 16)
        return red, green, blue
    end
end

utils_color.gradient_colors = function(start_color, end_color, total_length)
    local points = total_length - 2
    if points < 0 then
        points = 0
    end
    local start_red, start_green, start_blue = utils_color.get_values(
        start_color
    )
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
        "#" .. utils.hex(start_red) .. utils.hex(start_green) .. utils.hex(
            start_blue
        ),
    }
    for i = 1, points do
        gradient_colors[#gradient_colors + 1] = "#"
            .. utils.hex(utils.round_float(start_red + red_step * i))
            .. utils.hex(utils.round_float(start_green + green_step * i))
            .. utils.hex(utils.round_float(start_blue + blue_step * i))
    end
    gradient_colors[#gradient_colors + 1] = "#"
        .. utils.hex(end_red)
        .. utils.hex(end_green)
        .. utils.hex(end_blue)

    return gradient_colors
end

utils_color.display_gradient =
    function(buf, ns, line, start_color, end_color, width)
        width = width * 2
        local gradient = utils_color.gradient_colors(
            start_color,
            end_color,
            width
        )
        vim.api.nvim_buf_set_lines(
            buf,
            line,
            line,
            false,
            { string.rep("▌", width / 2) }
        )
        for i = 1, width do
            vim.api.nvim_set_hl(
                0,
                "ColortilsGradient" .. i,
                { fg = gradient[2 * i], bg = gradient[2 * i + 1] }
            )
        end
        for i = 1, width do
            vim.api.nvim_buf_add_highlight(
                buf,
                ns,
                "ColortilsGradient" .. i,
                line,
                3 * i - 1,
                3 * i
            )
        end
    end

return utils_color
