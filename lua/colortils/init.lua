local colortils = {}

colortils.settings = {
    register = "+",
    ---String: preview text. %s is color value
    color_preview = "█ %s",
    ---String: "hex"|"rgb"|"hsl"
    default_format = "hex",
    border = "rounded",
    mappings = {
        increment = "l",
        decrement = "h",
        increment_big = "L",
        decrement_big = "H",
        min_value = "0",
        max_value = "$",
        set_register_default_format = "<cr>",
        set_register_choose_format = "g<cr>",
        replace_default_format = "<m-cr>",
        replace_choose_format = "g<m-cr>",
        export = "E",
        set_value = "c",
        transparency = "T",
    },
}

local utils = require("colortils.utils")
local color_utils = require("colortils.utils.colors")
local css = require("colortils.css")
local log = require("colortils.log")

--- Gets a color to be used with the tools
---@param color? string
---@param invalid boolean
---@return table color_table
local function get_color(color, invalid)
    color = color or ""
    local color_table = color_utils.get_colors(color)
    -- check if table available, not empty and only found one color
    if color_table and color_table ~= {} and #color_table == 1 then
        return color_table[1]
    end
    color_table = color_utils.get_color_under_cursor(0)
    if color_table and color_table ~= {} then
        return color_table
    end
    if invalid then
        color = vim.fn.input("Input a valid color > ", "")
    else
        color = vim.fn.input("Input a color > ", "")
    end
    color_table = get_color(color, true)
    return color_table
end

local commands = {
    ["picker"] = function(args)
        local color = get_color(args.fargs[2])
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.picker")(hex_string)
    end,
    ["css"] = function(args)
        if args.fargs[2] == "list" then
            css.list_colors()
        end
    end,
    ["gradient"] = function(args)
        local color_1 = get_color(args.fargs[2])
        local color_2 = get_color(args.fargs[3])
        color_1 = color_1[1]
        color_2 = color_2[1]
        local hex_string_1 = "#"
            .. utils.hex(color_1.rgb_values[1])
            .. utils.hex(color_1.rgb_values[2])
            .. utils.hex(color_1.rgb_values[3])
        local hex_string_2 = "#"
            .. utils.hex(color_2.rgb_values[2])
            .. utils.hex(color_2.rgb_values[2])
            .. utils.hex(color_2.rgb_values[3])
        require("colortils.tools.gradients.colors")(hex_string_1, hex_string_2)
    end,
    ["greyscale"] = function(args)
        local color = get_color(args.fargs[2])
        color = color[1]
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.gradients.greyscale")(hex_string)
    end,
    ["lighten"] = function(args)
        local color = get_color(args.fargs[2])
        color = color[1]
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.lighten")(hex_string)
    end,
    ["darken"] = function(args)
        local color = get_color(args.fargs[2])
        color = color[1]
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.darken")(hex_string)
    end,
}

--- Executes command
---@param args table
local function exec_command(args)
    commands[args.fargs[1]](args)
end

--- Creates the `Colortils` command
local function create_command()
    vim.api.nvim_create_user_command("Colortils", function(args)
        exec_command(args)
    end, {
        desc = "Colortils command",
        -- complete = function()
        --     return { "picker" }
        -- end,
        -- complete = "file",
        nargs = "+",
    })
end

--- Main setup function
---@param update table
function colortils.setup(update)
    local updated_settings = vim.tbl_deep_extend("force", colortils.settings, update or {})
    local ok, err = pcall(utils.validate_settings, updated_settings)
    if not ok then
        log.warn("Invalid config:" .. err)
    else
        colortils.settings = updated_settings
    end
    create_command()
end

return colortils
