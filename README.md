# telescope-tabman.nvim

This is a telescope.nvim extension tabpages picker named `tabman`.

## Help you make better use of Neovim's Tabpage

This picker is similar to the builtin `buffers` picker, but its focus is on tabpages and windows instead.

## Why another telescope picker?
When a neovim user is having many split windows in different tabpages, switching between them using the buffers picker is usually difficult. Instead, by using the Tabman picker, user should be able to switch to the specific window on a specific tabpage.

I found this picker very useful when using neovim as an IDE, where different tabpages are usually holding different file types (e.g. js, css, json files on separate tabpages). In this case, switching by the buffers picker will mess up the workspace, and Tabman picker can speed up file switching and preserving the workspace layout.

## Installation
Basic installation with Packer is as simple as:
```lua
-- download the repo
use 'quantumsnowball/telescope-tabman.nvim'
-- register the extension with telescope
require('telescope').load_extension('tabman')
```

## Call the Tabman picker
To verify the installation is working, you should be able to run the picker by:
```vim
:Telescope tabman
```
Tabman as a telescope picker should be shown.

You can also call the picker in lua with telescope configs like this:
```lua
require('telescope').extensions.tabman.tabman()
```

or with some telescope picker options:
```lua
local opts = {
    -- ... some telescope picker opts
}
require('telescope').extensions.tabman.tabman(opts)
```

## Set you keymaps
Tabman does not come with default keymaps, your need to define your own. Example of one-time setup up with the keymap of `<leader>t` is as follows:
```lua
use {
    'quantumsnowball/telescope-tabman.nvim',
    config = function()
        local opts = {
            -- ... some telescope picker opts
        }
        vim.keymap.set('n', '<leader>t', function()
            require('telescope').extensions.tabman.tabman(opts)
        end)
    end
}
```

## Extension configs

The following settings are currently supported:

|Keys          |Type      |Descriptons          |Default  |
|-             |-         |-                    |-        |
|`prompt_title`|string    |set prompt title text|"Tabman" |

Provide these extension settings via telescope, e.g.:
```lua
require('telescope').setup({
    extensions = {
        tabman = {
            prompt_title = 'Tabman: find tabpages and windows'
        }
    } 
})
```
