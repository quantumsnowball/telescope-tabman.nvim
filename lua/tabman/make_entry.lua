local entry_display = require "telescope.pickers.entry_display"
local utils = require "telescope.utils"
local strings = require "plenary.strings"
local Path = require "plenary.path"


local handle_entry_index = function(opts, t, k)
    local override = ((opts or {}).entry_index or {})[k]
    if not override then
        return
    end

    local val, save = override(t, opts)
    if save then
        rawset(t, k, val)
    end
    return val
end

local make_entry = {}

make_entry.set_default_entry_mt = function(tbl, opts)
    return setmetatable({}, {
        __index = function(t, k)
            local override = handle_entry_index(opts, t, k)
            if override then
                return override
            end

            -- Only hit tbl once
            local val = tbl[k]
            if val then
                rawset(t, k, val)
            end

            return val
        end,
    })
end

make_entry.gen_from_tabpage = function(opts)
    opts = opts or {}

    local disable_devicons = opts.disable_devicons

    local icon_width = 0
    if not disable_devicons then
        local icon, _ = utils.get_devicons("fname", disable_devicons)
        icon_width = strings.strdisplaywidth(icon)
    end

    local displayer = entry_display.create {
        separator = " ",
        items = {
            { width = opts.tabidx_width },
            { width = 4 },
            { width = icon_width },
            { remaining = true },
        },
    }

    local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())

    local make_display = function(entry)
        -- tabidx_width + modes + icon + 3 spaces + : + lnum
        opts.__prefix = opts.tabidx_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
        local display_bufname = utils.transform_path(opts, entry.filename)
        local icon, hl_group = utils.get_devicons(entry.filename, disable_devicons)

        return displayer {
            { entry.tabidx, "TelescopeResultsNumber" },
            { entry.indicator, "TelescopeResultsComment" },
            { icon, hl_group },
            display_bufname .. ":" .. entry.lnum,
        }
    end

    return function(entry)
        local bufname = entry.info.name ~= "" and entry.info.name or "[No Name]"
        -- if bufname is inside the cwd, trim that part of the string
        bufname = Path:new(bufname):normalize(cwd)

        local hidden = entry.info.hidden == 1 and "h" or "a"
        local readonly = vim.api.nvim_buf_get_option(entry.bufnr, "readonly") and "=" or " "
        local changed = entry.info.changed == 1 and "+" or " "
        local indicator = entry.flag .. hidden .. readonly .. changed
        local line_count = vim.api.nvim_buf_line_count(entry.bufnr)

        return make_entry.set_default_entry_mt({
            value = bufname,
            ordinal = entry.tabidx .. " : " .. bufname,
            display = make_display,

            tabidx = entry.tabidx,
            winnr = entry.winnr,

            bufnr = entry.bufnr,
            filename = bufname,
            -- account for potentially stale lnum as getbufinfo might not be updated or from resuming buffers picker
            lnum = entry.info.lnum ~= 0 and math.max(math.min(entry.info.lnum, line_count), 1) or 1,
            indicator = indicator,
        }, opts)
    end
end

return make_entry
