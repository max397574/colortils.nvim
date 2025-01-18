local css = {}

local colors = {
    { "aliceblue", "#F0F8FF" },
    { "antiquewhite", "#FAEBD7" },
    { "aqua", "#00FFFF" },
    { "aquamarine", "#7FFFD4" },
    { "azure", "#F0FFFF" },
    { "beige", "#F5F5DC" },
    { "bisque", "#FFE4C4" },
    { "black", "#000000" },
    { "blanchedalmond", "#FFEBCD" },
    { "blue", "#0000FF" },
    { "blueviolet", "#8A2BE2" },
    { "brown", "#A52A2A" },
    { "burlywood", "#DEB887" },
    { "cadetblue", "#5F9EA0" },
    { "chartreuse", "#7FFF00" },
    { "chocolate", "#D2691E" },
    { "coral", "#FF7F50" },
    { "cornflowerblue", "#6495ED" },
    { "cornsilk", "#FFF8DC" },
    { "crimson", "#DC143C" },
    { "cyan", "#00FFFF" },
    { "darkblue", "#00008B" },
    { "darkcyan", "#008B8B" },
    { "darkgoldenrod", "#B8860B" },
    { "darkgray", "#A9A9A9" },
    { "darkgreen", "#006400" },
    { "darkkhaki", "#BDB76B" },
    { "darkmagenta", "#8B008B" },
    { "darkolivegreen", "#556B2F" },
    { "darkorange", "#FF8C00" },
    { "darkorchid", "#9932CC" },
    { "darkred", "#8B0000" },
    { "darksalmon", "#E9967A" },
    { "darkseagreen", "#8FBC8F" },
    { "darkslateblue", "#483D8B" },
    { "darkslategray", "#2F4F4F" },
    { "darkturquoise", "#00CED1" },
    { "darkviolet", "#9400D3" },
    { "deeppink", "#FF1493" },
    { "deepskyblue", "#00BFFF" },
    { "dimgray", "#696969" },
    { "dodgerblue", "#1E90FF" },
    { "firebrick", "#B22222" },
    { "floralwhite", "#FFFAF0" },
    { "forestgreen", "#228B22" },
    { "fuchsia", "#FF00FF" },
    { "gainsboro", "#DCDCDC" },
    { "ghostwhite", "#F8F8FF" },
    { "gold", "#FFD700" },
    { "goldenrod", "#DAA520" },
    { "gray", "#7F7F7F" },
    { "green", "#008000" },
    { "greenyellow", "#ADFF2F" },
    { "honeydew", "#F0FFF0" },
    { "hotpink", "#FF69B4" },
    { "indianred", "#CD5C5C" },
    { "indigo", "#4B0082" },
    { "ivory", "#FFFFF0" },
    { "khaki", "#F0E68C" },
    { "lavender", "#E6E6FA" },
    { "lavenderblush", "#FFF0F5" },
    { "lawngreen", "#7CFC00" },
    { "lemonchiffon", "#FFFACD" },
    { "lightblue", "#ADD8E6" },
    { "lightcoral", "#F08080" },
    { "lightcyan", "#E0FFFF" },
    { "lightgoldenrodyellow", "#FAFAD2" },
    { "lightgreen", "#90EE90" },
    { "lightgrey", "#D3D3D3" },
    { "lightpink", "#FFB6C1" },
    { "lightsalmon", "#FFA07A" },
    { "lightseagreen", "#20B2AA" },
    { "lightskyblue", "#87CEFA" },
    { "lightslategray", "#778899" },
    { "lightsteelblue", "#B0C4DE" },
    { "lightyellow", "#FFFFE0" },
    { "lime", "#00FF00" },
    { "limegreen", "#32CD32" },
    { "linen", "#FAF0E6" },
    { "magenta", "#FF00FF" },
    { "maroon", "#800000" },
    { "mediumaquamarine", "#66CDAA" },
    { "mediumblue", "#0000CD" },
    { "mediumorchid", "#BA55D3" },
    { "mediumpurple", "#9370DB" },
    { "mediumseagreen", "#3CB371" },
    { "mediumslateblue", "#7B68EE" },
    { "mediumspringgreen", "#00FA9A" },
    { "mediumturquoise", "#48D1CC" },
    { "mediumvioletred", "#C71585" },
    { "midnightblue", "#191970" },
    { "mintcream", "#F5FFFA" },
    { "mistyrose", "#FFE4E1" },
    { "moccasin", "#FFE4B5" },
    { "navajowhite", "#FFDEAD" },
    { "navy", "#000080" },
    { "navyblue", "#9FAFDF" },
    { "oldlace", "#FDF5E6" },
    { "olive", "#808000" },
    { "olivedrab", "#6B8E23" },
    { "orange", "#FFA500" },
    { "orangered", "#FF4500" },
    { "orchid", "#DA70D6" },
    { "palegoldenrod", "#EEE8AA" },
    { "palegreen", "#98FB98" },
    { "paleturquoise", "#AFEEEE" },
    { "palevioletred", "#DB7093" },
    { "papayawhip", "#FFEFD5" },
    { "peachpuff", "#FFDAB9" },
    { "peru", "#CD853F" },
    { "pink", "#FFC0CB" },
    { "plum", "#DDA0DD" },
    { "powderblue", "#B0E0E6" },
    { "purple", "#800080" },
    { "red", "#FF0000" },
    { "rosybrown", "#BC8F8F" },
    { "royalblue", "#4169E1" },
    { "saddlebrown", "#8B4513" },
    { "salmon", "#FA8072" },
    { "sandybrown", "#FA8072" },
    { "seagreen", "#2E8B57" },
    { "seashell", "#FFF5EE" },
    { "sienna", "#A0522D" },
    { "silver", "#C0C0C0" },
    { "skyblue", "#87CEEB" },
    { "slateblue", "#6A5ACD" },
    { "slategray", "#708090" },
    { "snow", "#FFFAFA" },
    { "springgreen", "#00FF7F" },
    { "steelblue", "#4682B4" },
    { "tan", "#D2B48C" },
    { "teal", "#008080" },
    { "thistle", "#D8BFD8" },
    { "tomato", "#FF6347" },
    { "turquoise", "#40E0D0" },
    { "violet", "#EE82EE" },
    { "wheat", "#F5DEB3" },
    { "white", "#FFFFFF" },
    { "whitesmoke", "#F5F5F5" },
    { "yellow", "#FFFF00" },
    { "yellowgreen", "#9ACD32" },
}

css.colors = colors

--- Get the value for a color
---@param color string Color name
---@return string
function css.get_color_value(color)
    for _, color_table in ipairs(colors) do
        if color_table[1] == color then
            return color_table[2]
        end
    end
    return ""
end

--- Gets the table for a color
---@param color string Color name
---@return table [name,value]
function css.get_color_table(color)
    for _, color_table in ipairs(colors) do
        if color_table[1] == color then
            return color_table
        end
    end
    return {}
end

--- Gets the colors formatted as a table of string
---@return table "color strings"
function css.get_formated_colors()
    local lines = {}
    for _, color in ipairs(colors) do
        table.insert(
            lines,
            string.upper(color[1]:sub(1, 1))
                .. color[1]:sub(2, -1)
                .. ":"
                .. string.rep(" ", 21 - #color[1])
                .. color[2]
        )
    end
    return lines
end

--- Lists colors in a floating window
function css.list_colors()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, css.get_formated_colors())
    for _, value in ipairs(require("colortils").settings.mappings.quit_window) do
        vim.keymap.set("n", value, "<cmd>q<CR>", { noremap = true, buffer = buf })
    end
    ---@diagnostic disable-next-line: unused-local
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)

    ---@diagnostic disable-next-line: unused-local
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        win = 0,
        width = 30,
        height = math.floor(height * 0.9),
        col = 12,
        row = math.floor(height * 0.05) - 1,
        border = require("colortils").settings.border,
        style = "minimal",
    })
    vim.api.nvim__set_option_value("modifiable", false, { buf = buf })
    -- try to attach colorizer
    pcall(vim.cmd, "ColorizerAttachToBuffer")
end

return css
