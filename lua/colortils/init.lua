local colortils = {}

colortils.settings = {
    register = "+",
    ---String: preview text. %s is color value
    color_preview = "█ %s",
    ---String: "hex"|"rgb"|"hsl"
    default_format = "hex",
    ---String: default color if no color is found
    default_color = "#000000",
    border = "rounded",
    background = "#FFFFFF",
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
        choose_background = "B",
        quit_window = { "q", "<esc>" },
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
        return get_color(colortils.settings.default_color, false)
    else
        color = vim.fn.input("Input a color > ", "")
    end
    color_table = get_color(color, true)
    return color_table
end

local commands = {
    ["picker"] = function(args)
        if css.get_color_value(args.fargs[2]) ~= "" then
            require("colortils.tools.picker")(css.get_color_value(args.fargs[2]))
            return
        end
        local color = get_color(args.fargs[2])
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        local alpha
        if color.transparency then
            alpha = color.rgb_values[4] or nil
        end
        require("colortils.tools.picker")(hex_string, alpha)
    end,
    ["css"] = function(args)
        if args.fargs[2] == "list" then
            css.list_colors()
        end
    end,
    ["gradient"] = function(args)
        local hex_string_1
        local hex_string_2
        if css.get_color_value(args.fargs[2]) ~= "" then
            hex_string_1 = css.get_color_value(args.fargs[2])
        else
            local color = get_color(args.fargs[2])
            hex_string_1 = "#"
                .. utils.hex(color.rgb_values[1])
                .. utils.hex(color.rgb_values[2])
                .. utils.hex(color.rgb_values[3])
        end
        if css.get_color_value(args.fargs[3]) ~= "" then
            hex_string_2 = css.get_color_value(args.fargs[3])
        else
            local color = get_color(args.fargs[3])
            hex_string_2 = "#"
                .. utils.hex(color.rgb_values[2])
                .. utils.hex(color.rgb_values[2])
                .. utils.hex(color.rgb_values[3])
        end
        require("colortils.tools.gradients.colors")(hex_string_1, hex_string_2)
    end,
    ["greyscale"] = function(args)
        if css.get_color_value(args.fargs[2]) ~= "" then
            require("colortils.tools.gradients.greyscale")(css.get_color_value(args.fargs[2]))
            return
        end
        local color = get_color(args.fargs[2])
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.gradients.greyscale")(hex_string)
    end,
    ["lighten"] = function(args)
        if css.get_color_value(args.fargs[2]) ~= "" then
            require("colortils.tools.lighten")(css.get_color_value(args.fargs[2]))
            return
        end
        local color = get_color(args.fargs[2])
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.lighten")(hex_string)
    end,
    ["darken"] = function(args)
        if css.get_color_value(args.fargs[2]) ~= "" then
            require("colortils.tools.darken")(css.get_color_value(args.fargs[2]))
            return
        end
        local color = get_color(args.fargs[2])
        local hex_string = "#"
            .. utils.hex(color.rgb_values[1])
            .. utils.hex(color.rgb_values[2])
            .. utils.hex(color.rgb_values[3])
        require("colortils.tools.darken")(hex_string)
    end,
}

--- Executes command
---@param args table
function colortils.exec_command(args)
    commands[args.fargs[1] or "picker"](args)
end

--- Creates the `Colortils` command
local function create_command()
    vim.api.nvim_create_user_command("Colortils", function(args)
        colortils.exec_command(args)
    end, {
        nargs = "*",
        complete = function(_, _)
            return vim.tbl_keys(commands)
        end,
        desc = "Colortils command",
    })
end

--- Main setup function
---@param update? table
function colortils.setup(update)
    local updated_settings = vim.tbl_deep_extend("force", colortils.settings, update or {})
    local ok, err = pcall(utils.validate_settings, updated_settings)
    if not ok then
        log.warn("Invalid config:" .. err)
    else
        colortils.settings = updated_settings
    end
    vim.api.nvim_set_hl(0, "ColortilsCurrentLine", { bold = true, default = true })
    create_command()
end

return colortils
