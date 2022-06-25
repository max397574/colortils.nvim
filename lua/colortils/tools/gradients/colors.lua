local color_utils = require("colortils.utils.colors")
local utils = require("colortils.utils")
local settings = require("colortils").settings
local idx = 1
local buf
local ns = vim.api.nvim_create_namespace("colortils_gradient")
local old_cursor = vim.opt.guicursor
local function get_color(invalid_color)
    local color
    if invalid_color then
        color = vim.fn.input("Input a valid color (#RRGGBB) > ", "")
    else
        color = vim.fn.input("Input a second color > ", "")
    end
    if not color:match("^#%x%x%x%x%x%x$") then
        color = get_color(true)
    end
    return color
end

local function set_marker()
    vim.api.nvim_buf_set_lines(
        buf,
        1,
        2,
        false,
        { string.rep(" ", math.floor(idx / 5) - 1) .. "^" }
    )
end

local function increase(amount)
    amount = amount or 1
    if idx >= 51 * 5 then
        return
    end
    idx = idx + amount
    if idx > 255 then
        idx = 255
    end
    set_marker()
end
local function decrease(amount)
    amount = amount or 1
    if idx <= 1 then
        return
    end
    idx = idx - amount
    if idx < 1 then
        idx = 1
    end
    set_marker()
end

return function(color, color_2)
    if not color_2 then
        color_2 = get_color()
    end
    buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = 51,
        col = 10,
        row = 5,
        style = "minimal",
        height = 5,
        border = settings.border,
    })
    color_utils.display_gradient(buf, ns, 0, color, color_2, 51)
    vim.opt.guicursor = "a:ver1-Normal/Normal"
    vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
            vim.opt.guicursor = old_cursor
        end,
    })

    local gradient_big = require("colortils.utils.colors").gradient_colors(
        color,
        color_2,
        255
    )
    local function update()
        vim.api.nvim_set_hl(0, "ColorPickerPreview", { fg = gradient_big[idx] })
        vim.api.nvim_buf_set_lines(buf, 2, 3, false, { gradient_big[idx] })
        vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 2, 0, -1)
    end

    vim.keymap.set("n", "l", function()
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
    vim.keymap.set("n", "q", "<cmd>q<CR>", {
        buffer = buf,
        noremap = true,
    })

    vim.keymap.set("n", "h", function()
        decrease()
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", "<cr>", function()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
        win = nil
        idx=0
        vim.fn.setreg(settings.register, gradient_big[idx])
    end, {
        buffer = buf,
        noremap = true,
    })
    vim.keymap.set("n", settings.mappings.decrement_big, function()
        decrease(5)
        update()
    end, {
        buffer = buf,
        noremap = true,
    })
    set_marker()
    vim.api.nvim_buf_set_lines(buf, 2, 3, false, { gradient_big[idx] })
    vim.api.nvim_set_hl(0, "ColorPickerPreview", { fg = gradient_big[idx] })
    vim.api.nvim_buf_add_highlight(buf, ns, "ColorPickerPreview", 2, 0, -1)
end
