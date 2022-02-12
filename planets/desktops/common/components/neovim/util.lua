function nnoremap(shortcut, command)
    vim.api.nvim_set_keymap("n", shortcut, command, { noremap = true, silent = true })
end

function inoremap(shortcut, command)
    vim.api.nvim_set_keymap("i", shortcut, command, { noremap = true, silent = true })
end