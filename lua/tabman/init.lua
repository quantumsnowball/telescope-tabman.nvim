local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local make_entry = require "tabman.make_entry"


local function tabman(opts)
    opts = opts or {}

    local tabnrs = vim.api.nvim_list_tabpages()

    if not next(tabnrs) then
        return
    end

    local wins = {}
    -- iterate through each tabpage for the current vim instance
    for tabidx, tabnr in ipairs(tabnrs) do
        -- in each tabpage, iterate through each window
        for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
            -- then get the corresponding buffer number inside that window
            local bufnr = vim.api.nvim_win_get_buf(winnr)
            -- if a window is holding a listed buffer, it will be added and shown in picker
            -- if multiple windows are holding the same buffer, multiple rows will be shown
            if vim.fn.buflisted(bufnr) == 1 then
                local flag = bufnr == vim.fn.bufnr "" and "%" or (bufnr == vim.fn.bufnr "#" and "#" or " ")
                local win = {
                    tabidx = tabidx,
                    winnr = winnr,
                    bufnr = bufnr,
                    flag = flag,
                    info = vim.fn.getbufinfo(bufnr)[1],
                }
                table.insert(wins, win)
            end
        end
    end

    -- selection index defaults to 1, then try to set it to the current window
    local default_selection_index = 1
    local current_winnr = vim.api.nvim_get_current_win()
    for i, win in ipairs(wins) do
        if win.winnr == current_winnr then
            default_selection_index = i
            break
        end
    end

    if not opts.tabidx_width then
        local max_tabidx = #tabnrs
        opts.tabidx_width = #tostring(max_tabidx)
    end

    pickers.new(opts, {
        prompt_title = "Tabman",
        finder = finders.new_table {
            results = wins,
            entry_maker = opts.entry_maker or make_entry.gen_from_tabpage(opts),
        },
        previewer = conf.grep_previewer(opts),
        sorter = conf.generic_sorter(opts),
        default_selection_index = default_selection_index,
        attach_mappings = function(prompt_bufnr)
            -- default action on <cr> is switch to that tabpage and focus to that window
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if selection == nil then
                    return
                end
                actions.close(prompt_bufnr)
                vim.api.nvim_set_current_win(selection.winnr)
            end)

            return true
        end,
    }):find()
end

return tabman
