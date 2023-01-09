-- log.lua
--
-- Inspired by rxi/log.lua
-- Modified by tjdevries and can be found at github.com/tjdevries/vlog.nvim
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

-- User configuration section
local default_config = {
    -- Name of the plugin. Prepended to log messages
    plugin = "colortils.nvim",

    -- Should print the output to neovim while running
    -- values: 'sync','async',false
    use_console = "async",

    -- Should write to a file
    use_file = true,

    -- Any messages above this level will be logged.
    level = "info",

    -- Level configuration
    modes = {
        { name = "trace", level = vim.log.levels.TRACE },
        { name = "debug", level = vim.log.levels.DEBUG },
        { name = "info", level = vim.log.levels.INFO },
        { name = "warn", level = vim.log.levels.WARN },
        { name = "error", level = vim.log.levels.ERROR },
    },

    -- Can limit the number of decimals displayed for floats
    float_precision = 0.01,
}

-- TODO: Try to fix problem with log
-- reference: https://github.com/max397574/colortils.nvim/runs/6658071550?check_suite_focus=true#step:5:22
if vim.g.running_from_colortils_test then
    default_config.use_file = false
end

-- {{{ NO NEED TO CHANGE
local log = {}

local unpack = unpack or table.unpack

function log.new(config, standalone)
    config = vim.tbl_deep_extend("force", default_config, config)

    local outfile = string.format("%s/%s.log", vim.api.nvim_call_function("stdpath", { "cache" }), config.plugin)

    local obj
    if standalone then
        obj = log
    else
        obj = config
    end

    local levels = {}
    for i, v in ipairs(config.modes) do
        levels[v.name] = i
    end

    local function round(x, increment)
        increment = increment or 1
        x = x / increment
        return (x > 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)) * increment
    end

    local function make_string(...)
        local t = {}
        for i = 1, select("#", ...) do
            local x = select(i, ...)

            if type(x) == "number" and config.float_precision then
                x = tostring(round(x, config.float_precision))
            elseif type(x) == "table" then
                x = vim.inspect(x)
            else
                x = tostring(x)
            end

            t[#t + 1] = x
        end
        return table.concat(t, " ")
    end

    local function log_at_level(level, level_config, message_maker, ...)
        -- Return early if we're below the config.level
        if level < levels[config.level] then
            return
        end
        local nameupper = level_config.name:upper()

        local msg = message_maker(...)
        local info = debug.getinfo(config.info_level or 2, "Sl")
        local lineinfo = info.short_src .. ":" .. info.currentline

        -- Output to console
        if config.use_console then
            local function log_to_console()
                local console_string = string.format("[%-6s%s] %s: %s", nameupper, os.date("%H:%M:%S"), lineinfo, msg)

                local split_console = vim.split(console_string, "\n")
                for _, v in ipairs(split_console) do
                    local formatted_msg = string.format("[%s] %s", config.plugin, v) -- vim.fn.escape(v, [["\]]))

                    local ok = pcall(vim.notify, string.format("%s", formatted_msg), level_config.level)
                    if not ok then
                        vim.api.nvim_out_write(msg .. "\n")
                    end
                end
            end
            if config.use_console == "sync" and not vim.in_fast_event() then
                log_to_console()
            else
                vim.schedule(log_to_console)
            end
        end

        -- Output to log file
        if config.use_file then
            local fp = assert(io.open(outfile, "a"))
            local str = string.format("[%-6s%s] %s: %s\n", nameupper, os.date(), lineinfo, msg)
            fp:write(str)
            fp:close()
        end
    end

    for i, x in ipairs(config.modes) do
        -- log.info("these", "are", "separated")
        obj[x.name] = function(...)
            return log_at_level(i, x, make_string, ...)
        end

        -- log.fmt_info("These are %s strings", "formatted")
        obj[("fmt_%s"):format(x.name)] = function(...)
            return log_at_level(i, x, function(...)
                local passed = { ... }
                local fmt = table.remove(passed, 1)
                local inspected = {}
                for _, v in ipairs(passed) do
                    table.insert(inspected, vim.inspect(v))
                end
                return string.format(fmt, unpack(inspected))
            end, ...)
        end

        -- log.lazy_info(expensive_to_calculate)
        obj[("lazy_%s"):format(x.name)] = function()
            return log_at_level(i, x, function(f)
                return f()
            end)
        end

        -- log.file_info("do not print")
        obj[("file_%s"):format(x.name)] = function(vals, override)
            local original_console = config.use_console
            config.use_console = false
            config.info_level = override.info_level
            log_at_level(i, x, make_string, unpack(vals))
            config.use_console = original_console
            config.info_level = nil
        end
    end

    return obj
end

log.new(default_config, true)
-- }}}

return log
