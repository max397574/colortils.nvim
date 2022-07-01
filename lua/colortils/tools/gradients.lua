local color_utils = require("colortils.utils.colors")
local settings = require("colortils").settings
local idx = 1
local buf
local ns = vim.api.nvim_create_namespace("colortils_gradient")
local old_cursor = vim.opt.guicursor

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
        width = 51,
        col = 10,
        row = 5,
        style = "minimal",
        height = 3,
        border = settings.border,
    })
    color_utils.display_gradient(buf, ns, 0, color, color_2, 51)
    vim.opt.guicursor = "a:ver1-Normal/Normal"
    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            vim.api.nvim_win_set_cursor(win, { 2, 1 })
        end,
        buffer = buf,
    })
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
        vim.fn.setreg(settings.register, gradient_big[idx])
        idx = 0
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
    vim.keymap.set("n", "$", function()
        idx = 255
        update()
    end, {
        buffer = buf,
    })
    vim.keymap.set("n", "0", function()
        idx = 1
        update()
    end, {
        buffer = buf,
    })
    update()
end
