local colortils = {}

colortils.settings = {
    register = "+",
    ---String: preview text. %s is color value
    color_preview = "█ %s",
    border = "rounded",
}

local utils = require("colortils.utils")
local css = require("colortils.css")
local log = require("colortils.log")

local red = 0
local green = 0
local blue = 0
local buf = nil
local win = nil
local ns = vim.api.nvim_create_namespace("ColorPicker")

local function set_picker_lines()
    local lines = {}
    local red_str = "Red:    "
        .. string.rep(" ", 3 - #utils.hex(red))
        .. utils.hex(red)
        .. " "
        .. utils.get_bar(red, 255, 15)
    table.insert(lines, red_str)
    local green_str = "Green:  "
        .. string.rep(" ", 3 - #utils.hex(green))
        .. utils.hex(green)
        .. " "
        .. utils.get_bar(green, 255, 15)
    table.insert(lines, green_str)
    local blue_str = "Blue:   "
        .. string.rep(" ", 3 - #utils.hex(blue))
        .. utils.hex(blue)
        .. " "
        .. utils.get_bar(blue, 255, 15)
    table.insert(lines, blue_str)
    table.insert(lines, "")
    if string.find(colortils.settings.color_preview, "%s") then
        table.insert(
            lines,
            string.format(
                colortils.settings.color_preview,
                "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue)
            )
        )
    else
        table.insert(lines, colortils.settings.color_preview)
    end
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

local function update_highlight()
    vim.api.nvim_set_hl(
        0,
        "ColorPickerPreview",
        { fg = "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue) }
    )
end

local function right()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    if not vim.tbl_contains({ 1, 2, 3 }, row) then
        return
    end
    if row == 1 and red < 255 then
        red = red + 1
    elseif row == 2 and green < 255 then
        green = green + 1
    elseif row == 3 and blue < 255 then
        blue = blue + 1
    end
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end

local function left()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    if not vim.tbl_contains({ 1, 2, 3 }, row) then
        return
    end
    if row == 1 and red > 0 then
        red = red - 1
    elseif row == 2 and green > 0 then
        green = green - 1
    elseif row == 3 and blue > 0 then
        blue = blue - 1
    end
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end

local function confirm()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, {})
    buf = nil
    win = nil
    vim.fn.setreg(
        colortils.settings.register,
        "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue)
    )
end

local function create_mappings()
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = buf })
    vim.keymap.set("n", "l", function()
        right()
    end, { buffer = buf })
    vim.keymap.set("n", "h", function()
        left()
    end, { buffer = buf })
    vim.keymap.set("n", "<cr>", function()
        confirm()
    end, {
        buffer = buf,
    })
end

colortils.color_picker = function()
    buf = vim.api.nvim_create_buf(false, true)
    create_mappings()
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        width = 30,
        col = 0,
        row = 0,
        style = "minimal",
        height = 5,
        border = colortils.settings.border,
    })
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end

local commands = {
    ["picker"] = function(args)
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
        colortils.color_picker()
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
