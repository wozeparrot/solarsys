---- General Config ----
-- utf-8 encoding
vim.opt.encoding = "utf-8"
-- enable mouse
vim.opt.mouse = "a"
-- set indent width
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.cmd("set expandtab")
vim.opt.autoindent = true
vim.opt.smartindent = true
-- set case handling
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- command line settings
vim.opt.cmdheight = 1
-- set some timeouts
vim.opt.updatetime = 300
vim.opt.tm = 500
vim.cmd("set shortmess+=c")
-- disable hidden bufferrs
vim.opt.hidden = false
-- split config
vim.opt.splitbelow = true
vim.opt.splitright = true
-- sign column config
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
-- disable bells
vim.opt.errorbells = false
vim.opt.visualbell = false
-- use system clipboard
vim.cmd("set clipboard+=unnamedplus")
-- syntax highlighting
vim.opt.syntax = "on"
vim.opt.filetype = "on"
vim.opt.termguicolors = true
vim.cmd("set t_Co=256")
-- map space to leader key
vim.cmd("let mapleader=\" \"")
vim.cmd("let maplocalleader=\" \"")
nnoremap("<space>", "<nop>")

---- Language Overrides ----
-- nix
vim.cmd("autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2")
-- c
vim.g.c_syntax_for_h = 1

---- LSP Config ----
local null_ls = require("null-ls")
local null_helpers = require("null-ls.helpers")
local null_methods = require("null-ls.methods")

local save_format = function(client)
    if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end
end
local default_on_attach = function(client)
    save_format(client)
end

null_ls.setup({
    diagnostics_format = "[#{m}] #{s} (#{c})",
    debounce = 250,
    default_timeout = 5000,
    sources = {
        null_ls.builtins.formatting.black.with({
            command = "black",
        }),
    },
    on_attach = default_on_attach,
})

-- lspkind
local lspkind = require("lspkind")
lspkind.init()

-- trouble
require("trouble").setup({})
nnoremap("<leader>xx", "<cmd>TroubleToggle<CR>")
nnoremap("<leader>xw", "<cmd>TroubleToggle lsp_worskpace_diagnostics<CR>")
nnoremap("<leader>xd", "<cmd>TroubleToggle lsp_document_diagnostics<CR>")
nnoremap("<leader>xq", "<cmd>TroubleToggle quickfix<CR>")
nnoremap("<leader>xl", "<cmd>TroubleToggle loclist<CR>")
nnoremap("<leader>xr", "<cmd>TroubleToggle lsp_references<CR>")

-- lightbulb
vim.cmd("autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()")

-- lspsaga
local saga = require("lspsaga")
saga.init_lsp_saga()
nnoremap("<leader>lf", "<cmd>lua require('lspsaga.provider').lsp_finder()<CR>")
nnoremap("<leader>lh", "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>")
nnoremap("<C-d>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>")
nnoremap("<C-f>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>")
nnoremap("<leader>lr", "<cmd>lua require('lspsaga.rename').rename()<CR>")
nnoremap("<leader>ld", "<cmd>lua require('lspsaga.provider').preview_definition()<CR>")
nnoremap("<leader>ll", "<cmd>lua require('lspsaga.diagnostic').show_line_diagnostics()<CR>")
nnoremap("<leader>lc", "<cmd>lua require('lspsaga.diagnostic').show_cursor_diagnostics()<CR>")
nnoremap("<leader>ca", "<cmd>lua require('lspsaga.codeaction').code_action()<CR>")

--- setup language servers ---
local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- zig
lspconfig.zls.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- nix
lspconfig.rnix.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- rust
lspconfig.rust_analyzer.setup({})
require("crates").setup({})
require("rust-tools").setup({
    server = {
        capabilities = capabilities,
        on_attach = default_on_attach,
    },
})
require("rust-tools.inlay_hints").set_inlay_hints()
-- python
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- lua
lspconfig.sumneko_lua.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- java
lspconfig.java_language_server.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
    cmd = { "java-language-server" },
})

---- Treesitter Config ----
local treesitter = require("nvim-treesitter.configs")
treesitter.setup({
    highlight = {
        enable = true,
        disable = {},
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            node_decremental = "grm",
            scope_incremental = "grb"
        },
    },
    autotag = {
        enable = true,
    },
})
-- set nvim to use treesitter folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
-- treesitter-context
require("treesitter-context").setup({
    enable = true,
    throttle = true,
    max_lines = 0,
    patterns = {
        default = {
            "class",
            "function",
            "method",
        },
    },
})

---- Telescope Config ----
local telescope = require("telescope")
telescope.setup({
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
        pickers = {
            find_command = {
                "fd",
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})
-- load extensions
telescope.load_extension("fzf")
telescope.load_extension("frecency")
telescope.load_extension("ui-select")
-- config keybindings
nnoremap("<leader>fd", "<cmd>Telescope find_files<CR>")
nnoremap("<leader>ff", "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<CR>")
nnoremap("<leader>fh", "<cmd>Telescope help_tags<CR>")
nnoremap("<leader>fvcw", "<cmd>Telescope git_commits<CR>")
nnoremap("<leader>fvcb", "<cmd>Telescope git_bcommits<CR>")
nnoremap("<leader>fvb", "<cmd>Telescope git_branches<CR>")
nnoremap("<leader>fvs", "<cmd>Telescope git_status<CR>")
nnoremap("<leader>ft", "<cmd>Telescope<CR>")
nnoremap("<leader>flsw", "<cmd>Telescope lsp_workspace_symbols<CR>")
nnoremap("<leader>flsd", "<cmd>Telescope lsp_document_symbols<CR>")
nnoremap("<leader>flr", "<cmd>Telescope lsp_references<CR>")
nnoremap("<leader>flc", "<cmd>Telescope lsp_code_actions<CR>")
nnoremap("<leader>flt", "<cmd>Telescope lsp_type_definitions<CR>")
nnoremap("<leader>fld", "<cmd>Telescope lsp_definitions<CR>")
nnoremap("<leader>fs", "<cmd>Telescope treesitter<CR>")

---- nvim-autopairs Config ----
require("nvim-autopairs").setup({})

---- nvim-cmp Config ----
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nvim_buf_get_lines
end
local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "treesitter" },
        { name = "path" },
        { name = "crates" },
        { name = "buffer" },
    },
    mapping = {
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable,
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({
            select = true,
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn['vsnip#available'](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn['vsnip#available'](-1) == 1 then
                feedkeys("<Plug>(vsnip-jump-prev)", "")
            end
        end, { 'i', 's' }),
    },
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind].." "..vim_item.kind

            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                vsnip = "[VSnip]",
                treesitter = "[TS]",
                path = "[Path]",
                crates = "[Crates]",
                buffer = "[Buffer]",
            })[entry.source.name]
            
            return vim_item
        end,
    },
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { text = "" } }))

---- indent-blankline Config ----
vim.cmd("highlight IndentBlankline guifg=#151510 gui=nocombine")
require("indent_blankline").setup({
    char_highlight_list = { "IndentBlankline" },
    show_current_context = true,
    show_trailing_blankline_indent = false,
})
-- TODO: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
vim.wo.colorcolumn = "99999"
vim.opt.list = true

---- nvim-cursorline Config ----
vim.g.cursorline_timeout = 500