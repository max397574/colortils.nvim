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
        transparency="T",
    },
}

local utils = require("colortils.utils")
local css = require("colortils.css")
local log = require("colortils.log")

--- Gets a color to be used with the tools
---@param color? string
---@param invalid boolean
---@return string Color
local function get_color(color, invalid)
    color = color or ""
    if color:match("^#%x%x%x%x%x%x$") then
        return color
    elseif color:match("^%x%x%x%x%x%x$") then
        return "#" .. color
    elseif not color and vim.fn.expand("<cword>"):match("^%x%x%x%x%x%x$") then
        return "#" .. vim.fn.expand("<cword>")
    end
    if invalid then
        color = vim.fn.input("Input a valid color > ", "#RRGGBB")
    else
        color = vim.fn.input("Input a color > ", "#RRGGBB")
    end
    if not color:match("^#%x%x%x%x%x%x$") then
        color = get_color(nil, true)
    end
    return color
end

local commands = {
    ["picker"] = function(args)
        local color = get_color(args.fargs[2])
        require("colortils.tools.picker")(color)
    end,
    ["css"] = function(args)
        if args.fargs[2] == "list" then
            css.list_colors()
        end
    end,
    ["gradient"] = function(args)
        local color_1 = get_color(args.fargs[2])
        local color_2 = get_color(args.fargs[3])
        require("colortils.tools.gradients.colors")(color_1, color_2)
    end,
    ["greyscale"] = function(args)
        local color = get_color(args.fargs[2])
        require("colortils.tools.gradients.greyscale")(color)
    end,
    ["lighten"] = function(args)
        local color = get_color(args.fargs[2])
        require("colortils.tools.lighten")(color)
    end,
    ["darken"] = function(args)
        local color = get_color(args.fargs[2])
        require("colortils.tools.darken")(color)
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
        complete = function()
            return { "picker" }
        end,
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
