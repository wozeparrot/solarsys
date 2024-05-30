function nnoremap(shortcut, command)
    vim.api.nvim_set_keymap("n", shortcut, command, { noremap = true, silent = true })
end

function inoremap(shortcut, command)
    vim.api.nvim_set_keymap("i", shortcut, command, { noremap = true, silent = true })
end

function tnoremap(shortcut, command)
    vim.api.nvim_set_keymap("t", shortcut, command, { noremap = true, silent = true })
end

local lazy_loaded = {}

function lazy_require(plugin, config)
    lazy_loaded[plugin] = config
end

vim.api.nvim_create_augroup("lazy_load", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
    group = "lazy_load",
    callback = function()
        for plugin, config in pairs(lazy_loaded) do
            local plug = require(plugin)
            if type(config) == "function" then
                config = config(plug)
            end
            plug.setup(config)
        end
        vim.api.nvim_clear_autocmds({ group = "lazy_load" })
    end,
})
