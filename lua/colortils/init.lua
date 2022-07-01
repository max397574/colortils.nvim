local colortils = {}

colortils.settings = {
    register = "+",
    ---String: preview text. %s is color value
    color_preview = "█ %s",
    ---String: "hex"|"rgb"|"hsl"
    default_format = "hex",
    border = "rounded",
    mappings = {
        increment_big = "L",
        decrement_big = "H",
    },
    window = {
        relative = "cursor",
        width = 30,
        col = 0,
        row = 0,
        height = 5,
    },
}

local utils = require("colortils.utils")
local css = require("colortils.css")
local log = require("colortils.log")

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

local function exec_command(args)
    commands[args.fargs[1]](args)
end

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

function colortils.setup(update)
    local updated_settings = vim.tbl_deep_extend(
        "force",
        colortils.settings,
        update or {}
    )
    local ok, err = pcall(utils.validate_settings, updated_settings)
    if not ok then
        log.warn("Invalid config:" .. err)
    else
        colortils.settings = updated_settings
    end
    create_command()
end

return colortils
