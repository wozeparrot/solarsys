local o = vim.o
local wo = vim.wo
local bo = vim.bo

-- General Config
o.syntax = 'on'
o.filetype = 'on'
o.expandtab = true
o.bs = '2'
o.tabstop = 2
o.shiftwidth = 2
o.autoindent = true
o.smartindent = true
o.smartcase = true
o.ignorecase = true
o.modeline = true
o.encoding = 'utf-8'
o.ruler = true
o.background = 'dark'
o.termguicolors = true
o.mouse = 'a'

-- LSP Config
require'lspconfig'.pyright.setup()
require'lspconfig'.rust_analyzer.setup()
require'lspconfig'.zls.setup()

-- Autocompletion Config
require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
        path = true;
        nvim_lsp = true;
    };
}

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return vim.fn['compe#complete']()
    end
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    else
        return t "<S-Tab>"
    end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

-- Treesitter Config
require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained";
    highlight = {
        enable = true;
    }
}