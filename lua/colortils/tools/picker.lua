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
local old_cursor_pos = { 0, 1 }
local transparency = nil

--- Updates the highlight used for the preview
local function update_highlight()
    vim.api.nvim_set_hl(
        0,
        "ColorPickerPreview",
        { fg = "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue) }
    )
    if transparency then
        vim.api.nvim_set_hl(0, "ColorPickerPreview", {
            fg = color_utils.blend_colors(
                "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue),
                "#"
                    .. string.format(
                        "%x",
                        vim.api.nvim_get_hl_by_name("Normal", true).background
                    ),
                (100 - transparency) / 100
            ),
        })
    end
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

local format_strings = {
    ["hex"] = function()
        if transparency then
            return "#"
                .. utils.hex(red)
                .. utils.hex(green)
                .. utils.hex(blue)
                .. utils.hex(transparency / 100 * 255)
        else
            return "#" .. utils.hex(red) .. utils.hex(green) .. utils.hex(blue)
        end
    end,
    ["rgb"] = function()
        if transparency then
            return "rgb("
                .. red
                .. ", "
                .. green
                .. ", "
                .. blue
                .. ", "
                .. transparency / 100
                .. ")"
        else
            return "rgb(" .. red .. ", " .. green .. ", " .. blue .. ")"
        end
    end,
    ["hsl"] = function()
        if transparency then
            local h, s, l, a = unpack(
                color_utils.rgb_to_hsl(red, green, blue, transparency / 100)
            )
            return "hsl(" .. h .. ", " .. s .. "%, " .. l .. "%, " .. a .. ")"
        else
            local h, s, l = unpack(
                color_utils.rgb_to_hsl(red, green, blue, transparency / 100)
            )
            return "hsl(" .. h .. ", " .. s .. "%, " .. l .. "%)"
        end
    end,
}

--- Sets the lines in the picker
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
                format_strings[colortils.settings.default_format]()
            )
        )
    else
        table.insert(lines, colortils.settings.color_preview)
    end
    if transparency then
        if transparency then
            local transparency_string = "Transparency: "
                .. string.rep(" ", 3 - #tostring(transparency))
                .. transparency
                .. " "
                .. utils.get_bar(transparency, 100, 10)
            table.insert(lines, transparency_string)
        end
    end
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

--- Adjusts a color value
---@param amount number
local function adjust_color(amount)
    local row = vim.api.nvim_win_get_cursor(win)[1]
    if not vim.tbl_contains({ 1, 2, 3, 6 }, row) then
        return
    end
    if row == 1 then
        red = utils.adjust_value(red, amount)
    elseif row == 2 then
        green = utils.adjust_value(green, amount)
    elseif row == 3 then
        blue = utils.adjust_value(blue, amount)
    elseif row == 6 then
        transparency = math.max(math.min(transparency + amount, 100), 0)
    end
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end

--- Confirm color and choose format
local function confirm_select()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, {})
    buf = nil
    win = nil
    vim.ui.select({
        "hex: " .. format_strings["hex"](),
        "rgb: " .. format_strings["rgb"](),
        "hsl: " .. format_strings["hsl"](),
    }, {
        prompt = "Choose format",
    }, function(item)
        item = item:sub(1, 3)
        vim.fn.setreg(colortils.settings.register, format_strings[item]())
        transparency = nil
    end)
end

--- Confirm color and save with default format
local function confirm()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, {})
    buf = nil
    win = nil
    vim.fn.setreg(
        colortils.settings.register,
        format_strings[colortils.settings.default_format]()
    )
    transparency = nil
end

local value = nil

--- Sets a color value to a certain value
---@param color_value number
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

--- Create the mappings for the picker buffer
local function create_mappings()
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
        win = nil
        transparency = nil
    end, {
        buffer = buf,
    })
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
    vim.keymap.set("n", "g<cr>", function()
        confirm_select()
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
    vim.keymap.set("n", "T", function()
        if not transparency then
            vim.api.nvim_win_set_height(win, 6)
            transparency = 0
            vim.cmd([[redraw]])
        else
            vim.api.nvim_win_set_height(win, 5)
            transparency = nil
        end
        update_highlight()
        set_picker_lines()
        vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
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
        zindex = 100,
        col = 1,
        row = 1,
        style = "minimal",
        height = 5,
        border = colortils.settings.border,
    })
    vim.api.nvim_set_hl(0, "ColortilsBlack", { fg = "#000000" })
    vim.opt.guicursor = "a:ver1-Normal/Normal"
    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(win)
            local row = old_cursor_pos[1]
            local bigger = false
            if
                cursor[1] > old_cursor_pos[1]
                or cursor[2] > old_cursor_pos[2]
            then
                bigger = true
                if transparency then
                    row = math.min((old_cursor_pos[1] + 1), 6)
                else
                    row = math.min((old_cursor_pos[1] + 1), 3)
                end
            elseif
                cursor[1] < old_cursor_pos[1]
                or cursor[2] < old_cursor_pos[2]
            then
                row = math.max(old_cursor_pos[1] - 1, 1)
            end
            if vim.tbl_contains({ 4, 5 }, row) then
                if bigger then
                    row = 6
                else
                    row = 3
                end
            end
            vim.api.nvim_win_set_cursor(win, { row, 0 })
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, 3)
            vim.api.nvim_buf_add_highlight(buf, ns, "Bold", row - 1, 0, -1)
            old_cursor_pos = { row, 0 }
        end,
        buffer = buf,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
            vim.opt.guicursor = old_cursor
        end,
    })
    update_highlight()
    set_picker_lines()
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 4, 0, -1)
end
