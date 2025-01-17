local color_utils = require("colortils.utils.colors")
local settings = require("colortils").settings
local colortils = require("colortils")
local utils = require("colortils.utils")

--- Sets the marker which indeicates position on the gradient
local function set_marker(state)
    vim.api.nvim_buf_set_lines(state.buf, 1, 2, false, { string.rep(" ", math.floor(state.idx / 5) - 1) .. "^" })
end

local format_strings = {
    ["hex"] = function(color, state)
        if state.transparency then
            return color .. utils.hex((1 - state.transparency / 100) * 255)
        else
            return color
        end
    end,
    ["hsl"] = function(color, state)
        local red, green, blue = color_utils.get_values(color)
        if state.transparency then
            local h, s, l, a = unpack(color_utils.rgb_to_hsl(red, green, blue, 1 - state.transparency / 100))
            return "hsl(" .. h .. ", " .. s .. "%, " .. l .. "%, " .. a .. ")"
        else
            local h, s, l = unpack(color_utils.rgb_to_hsl(red, green, blue))
            return "hsl(" .. h .. ", " .. s .. "%, " .. l .. "%)"
        end
    end,
    ["rgb"] = function(color, state)
        local red, green, blue = color_utils.get_values(color)
        if state.transparency then
            return "rgb(" .. red .. ", " .. green .. ", " .. blue .. ", " .. 1 - state.transparency / 100 .. ")"
        else
            return "rgb(" .. red .. ", " .. green .. ", " .. blue .. ")"
        end
    end,
}

local function update(colors, state)
    vim.api.nvim_set_option_value("modifiable", true, { buf = state.buf })
    vim.api.nvim_buf_set_lines(state.buf, 0, 1, false, {})
    color_utils.display_gradient(
        state.buf,
        state.ns,
        0,
        colors.first_color,
        colors.second_color,
        51,
        state.transparency and (1 - state.transparency / 100),
        state.transparency and colortils.settings.background
    )

    vim.api.nvim_set_hl(0, "ColorPickerPreview", { fg = colors.gradient_big[state.idx], bg = settings.background })

    local line = string.find(settings.color_preview, "%s")
            and string.format(
                settings.color_preview,
                format_strings[colortils.settings.default_format](colors.gradient_big[state.idx], state),
                state
            )
        or settings.color_preview

    set_marker(state)
    vim.api.nvim_buf_set_lines(state.buf, 2, 3, false, { line })
    vim.api.nvim_buf_add_highlight(state.buf, state.ns, "ColorPickerPreview", 2, 0, -1)
    if state.transparency then
        local transparency_string = "Transparency: "
            .. string.rep(" ", 3 - #tostring(state.transparency))
            .. state.transparency
            .. " "
            .. require("colortils.utils").get_bar(state.transparency, 100, 10)
        vim.api.nvim_buf_set_lines(state.buf, 3, 4, false, { transparency_string })
        vim.api.nvim_set_hl(0, "ColorPickerPreview", {
            fg = color_utils.blend_colors(
                colors.gradient_big[state.idx],
                colortils.settings.background,
                1 - state.transparency / 100
            ),
            bg = settings.background,
        })
    end
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })
    vim.api.nvim_buf_add_highlight(
        state.buf,
        state.ns,
        "ColortilsCurrentLine",
        vim.api.nvim_win_get_cursor(0)[1] - 1,
        0,
        -1
    )
end

--- Adjusts index
---@param amount number
local function adjust(amount, state)
    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    if not vim.tbl_contains({ 2, 4 }, row) then
        return
    end
    if row == 2 then
        state.idx = state.idx + amount
        state.idx = math.max(math.min(state.idx, 255), 1)
    else
        state.transparency = math.max(math.min(state.transparency + amount, 100), 0)
    end
    return state
end

local function toggle_transparency(colors, state)
    if not colors.alpha then
        colors.alpha = 1
    end
    if not state.transparency then
        vim.api.nvim_win_set_height(state.win, 4)
        state.transparency = 0
        vim.cmd([[redraw]])
    else
        vim.api.nvim_win_set_height(state.win, 3)
        state.transparency = nil
    end
    colors.gradient_big = require("colortils.utils.colors").get_blended_gradient(
        colors.first_color,
        colors.second_color,
        255,
        state.transparency and (1 - state.transparency / 100),
        state.transparency and colortils.settings.background
    )

    update(colors, state)
    vim.cmd([[redraw]])
    return colors
end

return function(color, color_2, alpha)
    settings = require("colortils").settings
    local state = {}
    local help_state = {}
    help_state.ns = vim.api.nvim_create_namespace("colortils_gradient_help")
    help_state.open = false
    state.ns = vim.api.nvim_create_namespace("colortils_gradient")
    state.idx = 1
    local colors = {}
    colors.first_color = color
    colors.second_color = color_2
    colors.alpha = alpha
    state.old_cursor_pos = { 0, 1 }
    local old_cursor = vim.opt.guicursor
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
    vim.api.nvim_win_set_hl_ns(state.win, state.ns)
    vim.api.nvim_set_option_value("cursorline", false, { win = state.win })
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
    if next(vim.api.nvim_get_hl(0, { name = "NormalFloat" })) == nil then
        vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    end
    local cursor_fg = vim.api.nvim_get_hl(0, { name = "Cursor" }).fg
    local cursor_bg = vim.api.nvim_get_hl(0, { name = "Cursor" }).bg
    vim.api.nvim_set_hl(0, "Cursor", {
        fg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg,
        bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg,
    })
    vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"

    vim.api.nvim_create_autocmd({
        "BufEnter",
    }, {
        callback = function()
            if state.buf and vim.api.nvim_get_current_buf() == state.buf or help_state.open then
                vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"
            else
                vim.opt.guicursor = old_cursor
                vim.api.nvim_set_hl(0, "Cursor", { fg = cursor_fg, bg = cursor_bg })
            end
        end,
    })

    colors.gradient_big = require("colortils.utils.colors").get_blended_gradient(
        colors.first_color,
        colors.second_color,
        255,
        state.transparency and (1 - state.transparency / 100),
        state.transparency and colortils.settings.background
    )

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(state.win)
            local row = state.old_cursor_pos[1]
            if cursor[1] == row and cursor[2] == state.old_cursor_pos[2] then
                return
            end
            local bigger = false
            if cursor[1] > state.old_cursor_pos[1] or cursor[2] > state.old_cursor_pos[2] then
                bigger = true
            end
            row = state.transparency and (bigger and 4 or 2) or 2
            vim.api.nvim_win_set_cursor(state.win, { row, 0 })
            state.old_cursor_pos = { row, 0 }
            update(colors, state)
        end,
        buffer = state.buf,
    })

    local function close()
        if help_state.open then
            vim.api.nvim_win_close(help_state.win, true)
            help_state.open = false
        end

        vim.cmd([[q]])
    end

    vim.keymap.set("n", colortils.settings.mappings.increment, function()
        state = adjust(1, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", settings.mappings.increment_big, function()
        state = adjust(5, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    for _, value in ipairs(settings.mappings.quit_window) do
        vim.keymap.set("n", value, function()
            close()
        end, {
            buffer = state.buf,
            noremap = true,
        })
    end
    vim.keymap.set("n", colortils.settings.mappings.export, function()
        if help_state.open then
            vim.api.nvim_win_close(help_state.win, true)
            help_state.open = false
        end
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        vim.ui.select(
            { "Picker", "Gradient", "Greyscale", "Lighten", "Darken" },
            { prompt = "Choose tool" },
            function(item)
                require("colortils.utils.tools").export(item, colors.gradient_big[state.idx], state.transparency)
                -- local tmp_idx = state.idx
                -- tools[item](colors.gradient_big[tmp_idx], state)
            end
        )
    end, {
        buffer = state.buf,
        noremap = true,
    })

    vim.keymap.set("n", colortils.settings.mappings.decrement, function()
        state = adjust(-1, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_default_format, function()
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})

        vim.fn.setreg(settings.register, format_strings[settings.default_format](colors.gradient_big[state.idx], state))
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_choose_format, function()
        if help_state.open then
            vim.api.nvim_win_close(help_state.win, true)
            help_state.open = false
        end

        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})

        vim.ui.select({
            "hex: " .. format_strings["hex"](colors.gradient_big[state.idx], state),
            "rgb: " .. format_strings["rgb"](colors.gradient_big[state.idx], state),
            "hsl: " .. format_strings["hsl"](colors.gradient_big[state.idx], state),
        }, {
            prompt = "Choose format",
        }, function(item)
            item = item:sub(1, 3)
            vim.fn.setreg(settings.register, format_strings[item](colors.gradient_big[state.idx], state))
        end)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_default_format, function()
        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        color_utils.replace_under_cursor(format_strings[settings.default_format](colors.gradient_big[state.idx], state))
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_choose_format, function()
        if help_state.open then
            vim.api.nvim_win_close(help_state.win, true)
            help_state.open = false
        end

        vim.api.nvim_win_close(state.win, true)
        vim.api.nvim_buf_delete(state.buf, {})
        vim.ui.select({
            "hex: " .. format_strings["hex"](colors.gradient_big[state.idx], state),
            "rgb: " .. format_strings["rgb"](colors.gradient_big[state.idx], state),
            "hsl: " .. format_strings["hsl"](colors.gradient_big[state.idx], state),
        }, {
            prompt = "Choose format",
        }, function(item)
            item = item:sub(1, 3)
            color_utils.replace_under_cursor(format_strings[item](colors.gradient_big[state.idx], state))
        end)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", settings.mappings.decrement_big, function()
        state = adjust(-5, state)
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.max_value, function()
        state.idx = 255
        update(colors, state)
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.min_value, function()
        state.idx = 1
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
        if help_state.open then
            vim.api.nvim_win_close(help_state.win, true)
            help_state.open = false
            return
        end
        help_state.open = true
        help_state.buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = help_state.buf })
        local lines = {
            "Keybindings",
            "Increment:                                     " .. colortils.settings.mappings.increment,
            "Decrement:                                     " .. colortils.settings.mappings.decrement,
            "Increment big:                                 " .. colortils.settings.mappings.increment_big,
            "Decrement big:                                 " .. colortils.settings.mappings.decrement_big,
            "Select first color:                            " .. colortils.settings.mappings.min_value,
            "Select last color:                             " .. colortils.settings.mappings.max_value,
            "Export to other tool:                          " .. colortils.settings.mappings.export,
            "Change background:                             " .. colortils.settings.mappings.choose_background,
            "Toggle transparency:                           " .. colortils.settings.mappings.transparency,
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
            "Choose format and replace color under cursor:  " .. colortils.settings.mappings.replace_choose_format,
        }
        vim.api.nvim_buf_set_lines(help_state.buf, 0, -1, false, lines)
        help_state.win = vim.api.nvim_open_win(help_state.buf, false, {
            relative = "editor",
            col = 63,
            row = 5,
            zindex = 100,
            width = 60,
            height = 13,
            border = "rounded",
            style = "minimal",
        })
        vim.api.nvim_buf_add_highlight(help_state.buf, help_state.ns, "Special", 0, 0, -1)
        for i = 1, 11, 1 do
            vim.api.nvim_buf_add_highlight(help_state.buf, help_state.ns, "String", i, 0, 47)
            vim.api.nvim_buf_add_highlight(help_state.buf, help_state.ns, "Keyword", i, 47, -1)
        end
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(help_state.win),
            callback = function()
                help_state.open = false
                help_state.buf = nil
            end,
        })
        vim.api.nvim_set_option_value("modifiable", false, { buf = help_state.buf })
    end, {
        buffer = state.buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.choose_background, function()
        local bg_color = require("colortils.utils.tools").get_color()
        local hex_color = "#"
            .. utils.hex(bg_color.rgb_values[1])
            .. utils.hex(bg_color.rgb_values[2])
            .. utils.hex(bg_color.rgb_values[3])

        require("colortils").settings.background = hex_color
        settings = require("colortils").settings
        update(colors, state)
    end, {
        buffer = state.buf,
        noremap = true,
    })
    if colors.alpha then
        state.transparency = (1 - colors.alpha) * 100
        vim.api.nvim_win_set_height(state.win, 4)
    end
    update(colors, state)
    vim.api.nvim_win_set_cursor(state.win, { 2, 0 })
end
