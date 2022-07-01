local buf
local win
local red = 0
local green = 0
local blue = 0
local colortils = require("colortils")
local utils = require("colortils.utils")
local color_utils = require("colortils.utils.colors")
local ns = vim.api.nvim_create_namespace("ColorPicker")
local old_cursor = vim.opt.guicursor

local function update_highlight()
    vim.api.nvim_set_hl(
        0,
        "ColorPickerPreview",
        { fg = "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue) }
    )
end

local color_values = {
    ["1"] = function(value)
        red = value
    end,
    ["2"] = function(value)
        green = value
    end,
    ["3"] = function(value)
        blue = value
    end,
}

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

local function adjust_color(amount)
    local row = vim.api.nvim_win_get_cursor(win)[1]
    if not vim.tbl_contains({ 1, 2, 3 }, row) then
        return
    end
    if row == 1 then
        red = utils.adjust_value(red, amount)
    elseif row == 2 then
        green = utils.adjust_value(green, amount)
    elseif row == 3 then
        blue = utils.adjust_value(blue, amount)
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

local value = nil

local function set_color_value(color_value)
    color_value = math.min(math.max(color_value, 0), 255)
    local row = vim.api.nvim_win_get_cursor(win)[1]
    if not vim.tbl_contains({ 1, 2, 3 }, row) then
        return
    end
    color_values[tostring(row)](color_value)
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end

local function set_value()
    local char_nr = vim.fn.getchar()
    local char = vim.fn.nr2char(char_nr)
    if not char:match("%d") then
        vim.api.nvim_input(char)
        value = nil
        return
    else
        if value then
            value = value .. char
        else
            value = char
        end
    end
    set_color_value(tonumber(value))
    vim.cmd("redraw")
    set_value()
end

local function create_mappings()
    vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = buf })
    vim.keymap.set("n", "c", function()
        set_value()
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "l", function()
        adjust_color(1)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "h", function()
        adjust_color(-1)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.increment_big, function()
        adjust_color(5)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.decrement_big, function()
        adjust_color(-5)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "<cr>", function()
        confirm()
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "$", function()
        set_color_value(255)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "0", function()
        set_color_value(0)
    end, {
        buffer = buf,
    })
end

return function(color)
    red, green, blue = color_utils.get_values(color)
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
    vim.opt.guicursor = "a:ver1-Normal/Normal"
    vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
            vim.opt.guicursor = old_cursor
        end,
    })
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end
