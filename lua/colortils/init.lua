local colortils = {}

colortils.settings = {
    register = "+",
    ---String: preview text. %s is color value
    color_preview = "█ %s",
    border = "rounded",
    mappings = {
        increment_big = "w",
        decrement_big = "b",
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

local commands = {
    ["picker"] = function(args)
        local red, green, blue
        local color = args.fargs[2] or nil
        if
            not color
            and utils.validate_color_numbers(vim.fn.expand("<cword>"))
        then
            color = vim.fn.expand("<cword>")
        end
        if color and utils.validate_color_numbers(color) then
            red = tonumber(color:sub(1, 2), 16)
            green = tonumber(color:sub(3, 4), 16)
            blue = tonumber(color:sub(5, 6), 16)
        end
        require("colortils.tools.picker")(
            "#"
                .. (red and utils.hex(red) or "00")
                .. (green and utils.hex(green) or "00")
                .. (blue and utils.hex(blue) or "00")
        )
    end,
    ["css"] = function(args)
        if args.fargs[2] == "list" then
            css.list_colors()
        end
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

colortils.setup = function(update)
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
