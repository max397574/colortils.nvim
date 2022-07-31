local color_utils = require("colortils.utils.colors")
local settings = require("colortils").settings
local idx = 1
local buf
local ns = vim.api.nvim_create_namespace("colortils_gradient")
local help_ns = vim.api.nvim_create_namespace("colortils_gradient_help")
local old_cursor = vim.opt.guicursor
local colortils = require("colortils")
local help_is_open = false
local help_window

--- Sets the marker which indeicates position on the gradient
local function set_marker()
    vim.api.nvim_buf_set_lines(
        buf,
        1,
        2,
        false,
        { string.rep(" ", math.floor(idx / 5) - 1) .. "^" }
    )
end

--- Increases index
---@param amount number
local function increase(amount)
    amount = amount or 1
    if idx >= 51 * 5 then
        return
    end
    idx = idx + amount
    idx = math.min(idx, 255)
end

--- Decreases index
---@param amount number
local function decrease(amount)
    amount = amount or 1
    if idx <= 1 then
        return
    end
    idx = idx - amount
    idx = math.max(idx, 1)
end

return function(color, color_2)
    buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        zindex = 90,
        width = 51,
        col = 10,
        row = 5,
        style = "minimal",
        height = 3,
        border = settings.border,
    })
    vim.api.nvim_win_set_option(win, "cursorline", false)
    color_utils.display_gradient(buf, ns, 0, color, color_2, 51)
    if vim.api.nvim_exec("hi NormalFloat", true):match("NormalFloat%s*xxx%s*cleared") then
        vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    end
    vim.api.nvim_set_hl(0, "Cursor", {
        fg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
        bg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background,
    })
    vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"
    local cursor_fg = vim.api.nvim_get_hl_by_name("Cursor", true).foreground
    local cursor_bg = vim.api.nvim_get_hl_by_name("Cursor", true).background

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            vim.api.nvim_win_set_cursor(win, { 2, 1 })
        end,
        buffer = buf,
    })
    vim.api.nvim_create_autocmd({
        "BufEnter",
    }, {
        callback = function()
            if buf and vim.api.nvim_get_current_buf() == buf or help_is_open then
                vim.opt_local.guicursor = "a:ver1-Cursor/Cursor"
            else
                vim.opt.guicursor = old_cursor
                vim.api.nvim_set_hl(0, "Cursor", { fg = cursor_fg, bg = cursor_bg })
            end
        end,
    })

    local gradient_big = require("colortils.utils.colors").gradient_colors(color, color_2, 255)
    local function update()
        vim.api.nvim_set_hl(0, "ColorPickerPreview", { fg = gradient_big[idx] })
        local line
        if string.find(settings.color_preview, "%s") then
            line = string.format(settings.color_preview, gradient_big[idx])
        else
            line = settings.color_preview
        end

        set_marker()
        vim.api.nvim_buf_set_lines(buf, 2, 3, false, { line })
        vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 2, 0, -1)
    end
    local function get_color(invalid)
        local input_color
        if invalid then
            input_color = vim.fn.input("Input a valid color > ", "#RRGGBB")
        else
            input_color = vim.fn.input("Input a color > ", "#RRGGBB")
        end
        if not input_color:match("^#%x%x%x%x%x%x$") then
            input_color = get_color(true)
        end
        return input_color
    end

    local tools = {
        ["Picker"] = function(hex_color)
            require("colortils.tools.picker")(hex_color)
        end,
        ["Gradient"] = function(hex_color)
            local second_color = get_color()
            require("colortils.tools.gradients.colors")(hex_color, second_color)
        end,
        ["Greyscale"] = function(hex_color)
            require("colortils.tools.gradients.greyscale")(hex_color)
        end,
        ["Lighten"] = function(hex_color)
            require("colortils.tools.lighten")(hex_color)
        end,
        ["Darken"] = function(hex_color)
            require("colortils.tools.darken")(hex_color)
        end,
    }

    local function export()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
        win = nil
        vim.ui.select(
            { "Picker", "Gradient", "Greyscale", "Lighten", "Darken" },
            { prompt = "Choose tool" },
            function(item)
                local tmp_idx = idx
                idx = 1
                tools[item](gradient_big[tmp_idx])
            end
        )
    end

    local format_strings = {
        ["hex"] = function()
            return gradient_big[idx]
        end,
        ["rgb"] = function()
            local picked_color = gradient_big[idx]
            return "rgb("
                .. tonumber(picked_color:sub(2, 3), 16)
                .. ", "
                .. tonumber(picked_color:sub(4, 5), 16)
                .. ", "
                .. tonumber(picked_color:sub(6, 7), 16)
                .. ")"
        end,
        ["hsl"] = function()
            local picked_color = gradient_big[idx]
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
        vim.cmd([[q]])
    end

    vim.keymap.set("n", colortils.settings.mappings.increment, function()
        increase()
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", settings.mappings.increment_big, function()
        increase(5)
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", "q", function()
        close()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.export, function()
        export()
    end, {
        buffer = buf,
        noremap = true,
    })

    vim.keymap.set("n", colortils.settings.mappings.decrement, function()
        decrease()
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_default_format, function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
        win = nil
        vim.fn.setreg(settings.register, format_strings[settings.default_format]())
        idx = 1
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.set_register_choose_format, function()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end

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
            vim.fn.setreg(settings.register, format_strings[item]())
            idx = 1
        end)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_default_format, function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
        win = nil
        color_utils.replace_under_cursor(format_strings[settings.default_format]())
        idx = 1
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.replace_choose_format, function()
        if help_is_open then
            vim.api.nvim_win_close(help_window, true)
            help_is_open = false
        end

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
            color_utils.replace_under_cursor(format_strings[item]())
            idx = 1
        end)
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", settings.mappings.decrement_big, function()
        decrease(5)
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", colortils.settings.mappings.max_value, function()
        idx = 255
        update()
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", colortils.settings.mappings.min_value, function()
        idx = 1
        update()
    end, {
        buffer = buf,
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
        buffer = buf,
    })
    update()
end
