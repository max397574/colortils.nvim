local color_utils = require("colortils.utils.colors")
local settings = require("colortils").settings
local idx = 1
local utils = require("colortils.utils")
local help_ns = vim.api.nvim_create_namespace("colortils_gradient_help")
local old_cursor = vim.opt.guicursor
local colortils = require("colortils")
local help_is_open = false
local help_window
local old_cursor_pos = { 0, 1 }

--- Sets the marker which indeicates position on the gradient
local function set_marker(state)
    vim.api.nvim_buf_set_lines(
        state.buf,
        1,
        2,
        false,
        { string.rep(" ", math.floor(idx / 5) - 1) .. "^" }
    )
end

local function update(colors, state)
    vim.api.nvim_buf_set_option(state.buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buf, 0, 1, false, {})
    if state.transparency then
        color_utils.display_gradient(
            state.buf,
            state.ns,
            0,
            colors.first_color,
            colors.second_color,
            51,
            state.transparency / 100,
            colortils.settings.background
        )
    else
        color_utils.display_gradient(
            state.buf,
            state.ns,
            0,
            colors.first_color,
            colors.second_color,
            51
        )
    end

    vim.api.nvim_set_hl(0, "ColorPickerPreview", { fg = colors.gradient_big[idx] })
    if state.transparency then
        vim.api.nvim_set_hl(0, "ColorPickerPreview", {
            fg = color_utils.blend_colors(
                colors.gradient_big[idx],
                colortils.settings.background,
                state.transparency / 100
            ),
        })
    end

    local line
    if string.find(settings.color_preview, "%s") then
        line = string.format(settings.color_preview, colors.gradient_big[idx])
    else
        line = settings.color_preview
    end

    set_marker(state)
    vim.api.nvim_buf_set_lines(state.buf, 2, 3, false, { line })
    vim.api.nvim_buf_add_highlight(state.buf, state.ns, "ColorPickerPreview", 2, 0, -1)
    if state.transparency then
        local transparency_string = "Transparency: "
            .. string.rep(" ", 3 - #tostring(100 - state.transparency))
            .. 100 - state.transparency
            .. " "
            .. require("colortils.utils").get_bar(100 - state.transparency, 100, 10)
        vim.api.nvim_buf_set_lines(state.buf, 3, 4, false, { transparency_string })
    end
    vim.api.nvim_buf_set_option(state.buf, "modifiable", false)
    vim.api.nvim_buf_add_highlight(
        state.buf,
        state.ns,
        "Bold",
        vim.api.nvim_win_get_cursor(0)[1] - 1,
        0,
        -1
    )
end

--- Increases index
---@param amount number
local function increase(amount, state)
    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    if not vim.tbl_contains({ 2, 4 }, row) then
        return
    end
    if row == 2 then
        idx = idx + amount
        idx = math.min(idx, 255)
    else
        state.transparency = math.max(state.transparency - amount, 0)
    end
end

--- Decreases index
---@param amount number
local function decrease(amount, state)
    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    if not vim.tbl_contains({ 2, 4 }, row) then
        return
    end
    if row == 2 then
        idx = idx - amount
        idx = math.max(idx, 1)
    else
        state.transparency = math.min(state.transparency + amount, 100)
    end
end

local function toggle_transparency(colors, state)
    if not colors.alpha then
        colors.alpha = 1
    end
    if not state.transparency then
        vim.api.nvim_win_set_height(state.win, 4)
        state.transparency = 100
        vim.cmd([[redraw]])
    else
        vim.api.nvim_win_set_height(state.win, 3)
        state.transparency = nil
    end
    if state.transparency then
        colors.gradient_big = require("colortils.utils.colors").get_blended_gradient(
            colors.first_color,
            colors.second_color,
            255,
            colors.alpha,
            colortils.settings.background
        )
    else
        colors.gradient_big = require("colortils.utils.colors").gradient_colors(
            colors.first_color,
            colors.second_color,
            255
        )
    end

    update(colors, state)
    vim.cmd([[redraw]])
    return colors
end

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

local tools = {
    ["Picker"] = function(hex_color, state)
        require("colortils.tools.picker")(hex_color, state.transparency / 100)
    end,
    ["Gradient"] = function(hex_color, state)
        local color_2 = get_color()
        local hex_color_2 = "#"
            .. utils.hex(color_2.rgb_values[1])
            .. utils.hex(color_2.rgb_values[2])
            .. utils.hex(color_2.rgb_values[3])
        require("colortils.tools.gradients.colors")(
            hex_color,
            hex_color_2,
            state.transparency / 100
        )
    end,
    ["Greyscale"] = function(hex_color, state)
        require("colortils.tools.gradients.greyscale")(hex_color, state.transparency / 100)
    end,
    ["Lighten"] = function(hex_color, state)
        require("colortils.tools.lighten")(hex_color, state.transparency / 100)
    end,
    ["Darken"] = function(hex_color, state)
        require("colortils.tools.darken")(hex_color, state.transparency / 100)
    end,
}

return function(color, color_2, alpha)
    local state = {}
    state.ns = vim.api.nvim_create_namespace("colortils_gradient")
    local colors = {}
    colors.first_color = color
    colors.second_color = color_2
    colors.alpha = alpha
    old_cursor_pos = { 0, 1 }
    state.buf = vim.api.nvim_create_buf(false, true)
    state.win = vim.api.nvim_open_win(state.buf, true, {
        relative = "editor",
        zindex = 90,
        width = 51,
        col = 10,
        row = 5,
        style = "minimal",
        height = 3,
        border = settings.border,
    })
    vim.api.nvim_win_set_option(state.win, "cursorline", false)
    color_utils.display_gradient(
        state.buf,
        state.ns,
        0,
        colors.first_color,
        colors.second_color,
        51,
        colors.alpha,
        colortils.settings.background
    )
    if vim.api.nvim_exec("hi NormalFloat", true):match("NormalFloat%s*xxx%s*cleared") then
        vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    end
    local cursor_fg = vim.api.nvim_get_hl_by_name("Cursor", true).foreground
    local cursor_bg = vim.api.nvim_get_hl_by_name("Cursor", true).background
    vim.api.nvim_set_hl(0, "Cursor", {
        fg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
        bg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
    })
    vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"

    vim.api.nvim_create_autocmd({
        "BufEnter",
    }, {
        callback = function()
            if state.buf and vim.api.nvim_get_current_buf() == state.buf or help_is_open then
                vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"
            else
                vim.opt.guicursor = old_cursor
                vim.api.nvim_set_hl(0, "Cursor", { fg = cursor_fg, bg = cursor_bg })
            end
        end,
    })

    if state.transparency then
        colors.gradient_big = require("colortils.utils.colors").get_blended_gradient(
            colors.first_color,
            colors.second_color,
            255,
            colors.alpha,
            colortils.settings.background
        )
    else
        colors.gradient_big = require("colortils.utils.colors").gradient_colors(
            colors.first_color,
            colors.second_color,
            255
        )
    end

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(state.win)
            local row = old_cursor_pos[1]
            if cursor[1] == row and cursor[2] == old_cursor_pos[2] then
                return
            end
            local bigger = false
            if cursor[1] > old_cursor_pos[1] or cursor[2] > old_cursor_pos[2] then
                bigger = true
            end
            if state.transparency then
                if bigger then
                    row = 4
                else
                    row = 2
                end
            else
                row = 2
            end
            vim.api.nvim_win_set_cursor(state.win, { row, 0 })
            old_cursor_pos = { row, 0 }
            update(colors, state)
        end,
        buffer = state.buf,
    })

    local function export()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        vim.ui.select(
            { "Picker", "Gradient", "Greyscale", "Lighten", "Darken" },
            { prompt = "Choose tool" },
            function(item)
                local tmp_idx = idx
                idx = 1
                tools[item](colors.gradient_big[tmp_idx], state)
            end
        )
    end

    local format_strings = {
        ["hex"] = function()
            return colors.gradient_big[idx]
        end,
        ["rgb"] = function()
            local picked_color = colors.gradient_big[idx]
            return "rgb("
                .. tonumber(picked_color:sub(2, 3), 16)
                .. ", "
                .. tonumber(picked_color:sub(4, 5), 16)
                .. ", "
                .. tonumber(picked_color:sub(6, 7), 16)
                .. ")"
        end,
        ["hsl"] = function()
            local picked_color = colors.gradient_big[idx]
            local h, s, l = unpack(
                color_utils.rgb_to_hsl(
                    tonumber(picked_color:sub(2, 3), 16),
                    tonumber(picked_color:sub(4, 5), 16),
                    tonumber(picked_color:sub(6, 7), 16)
                )
            )
            return "hsl(" .. h .. ", " .. s .. "%, " .. l .. "%)"
        end,
    }

    local function close()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end
        idx = 1

        vim.cmd([[q]])
    end

    vim.keymap.set("n", colortils.settings.mappings.increment, function()
        increase(1, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", settings.mappings.increment_big, function()
        increase(5, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", "q", function()
        close()
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.export, function()
        export()
    end, {
        buffer = state.buf,
        noremap = true,
    })

    vim.keymap.set("n", colortils.settings.mappings.decrement, function()
        decrease(1, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_default_format, function()
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})

        vim.fn.setreg(settings.register, format_strings[settings.default_format]())
        idx = 1
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_choose_format, function()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end

        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})

        vim.ui.select({
            "hex: " .. format_strings["hex"](),
            "rgb: " .. format_strings["rgb"](),
            "hsl: " .. format_strings["hsl"](),
        }, {
            prompt = "Choose format",
        }, function(item)
            item = item:sub(1, 3)
            vim.fn.setreg(settings.register, format_strings[item]())
            idx = 1
        end)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_default_format, function()
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        color_utils.replace_under_cursor(format_strings[settings.default_format]())
        idx = 1
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_choose_format, function()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end

        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        vim.ui.select({
            "hex: " .. format_strings["hex"](),
            "rgb: " .. format_strings["rgb"](),
            "hsl: " .. format_strings["hsl"](),
        }, {
            prompt = "Choose format",
        }, function(item)
            item = item:sub(1, 3)
            color_utils.replace_under_cursor(format_strings[item]())
            idx = 1
        end)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", settings.mappings.decrement_big, function()
        decrease(5, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.max_value, function()
        idx = 255
        update(colors, state)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.min_value, function()
        idx = 1
        update(colors, state)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.transparency, function()
        colors = toggle_transparency(colors, state)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", "?", function()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
            return
        end
        help_is_open = true
        local help_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(help_buf, "bufhidden", "wipe")
        local lines = {
            "Keybindings",
            "Increment:                                     "
                .. colortils.settings.mappings.increment,
            "Decrement:                                     "
                .. colortils.settings.mappings.decrement,
            "Increment big:                                 "
                .. colortils.settings.mappings.increment_big,
            "Decrement big:                                 "
                .. colortils.settings.mappings.decrement_big,
            "Select first color:                            "
                .. colortils.settings.mappings.min_value,
            "Select last color:                             "
                .. colortils.settings.mappings.max_value,
            "Export to other tool:                          " .. colortils.settings.mappings.export,
            "Toggle transparency:                           "
                .. colortils.settings.mappings.transparency,
            "Save to register   `"
                .. colortils.settings.register
                .. "` with format "
                .. colortils.settings.default_format
                .. ":        "
                .. colortils.settings.mappings.set_register_default_format,
            "Choose format and save to register `"
                .. colortils.settings.register
                .. "`:        "
                .. colortils.settings.mappings.set_register_choose_format,
            "Replace color under cursor with format "
                .. colortils.settings.default_format
                .. ":    "
                .. colortils.settings.mappings.replace_default_format,
            "Choose format and replace color under cursor:  "
                .. colortils.settings.mappings.replace_choose_format,
        }
        vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, lines)
        help_window = vim.api.nvim_open_win(help_buf, false, {
            relative = "editor",
            col = 63,
            row = 5,
            zindex = 100,
            width = 60,
            height = 12,
            border = "rounded",
            style = "minimal",
        })
        vim.api.nvim_buf_add_highlight(help_buf, help_ns, "Special", 0, 0, -1)
        for i = 1, 11, 1 do
            vim.api.nvim_buf_add_highlight(help_buf, help_ns, "String", i, 0, 47)
            vim.api.nvim_buf_add_highlight(help_buf, help_ns, "Keyword", i, 47, -1)
        end
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(help_window),
            callback = function()
                help_is_open = false
                help_window = nil
                help_buf = nil
            end,
        })
        vim.api.nvim_buf_set_option(help_buf, "modifiable", false)
    end, {
        buffer = state.buf,
    })
    if colors.alpha then
        state.transparency = colors.alpha * 100
        vim.api.nvim_win_set_height(state.win, 4)
    end
    update(colors, state)
    vim.api.nvim_win_set_cursor(state.win, { 2, 0 })
end
