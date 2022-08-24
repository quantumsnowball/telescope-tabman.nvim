local state = require('tabman.state')


return require("telescope").register_extension {
    setup = function(ext_config)
        -- access extension config and user config
        state['prompt_title'] = ext_config.prompt_title or "Tabman"
    end,
    exports = {
        tabman = require("tabman")
    },
}
