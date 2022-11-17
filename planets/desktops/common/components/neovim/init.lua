---- General Config ----
-- utf-8 encoding
vim.opt.encoding = "utf-8"
-- enable mouse
vim.opt.mouse = "a"
-- enable lists
vim.opt.list = true
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
-- enable hidden bufferrs
vim.opt.hidden = true
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
-- map space to leader key
vim.cmd('let mapleader=" "')
vim.cmd('let maplocalleader=" "')
nnoremap("<space>", "<nop>")

---- Keybindings ----
nnoremap("<leader>tt", "<cmd>tabnew<CR>")
nnoremap("<leader>tm", "<cmd>tabp<CR>")
nnoremap("<leader>tn", "<cmd>tabn<CR>")
nnoremap("<leader>bd", "<cmd>lua require('bufdelete').bufdelete(0, false)<CR>")
nnoremap("//", "<cmd>noh<CR>")

---- Ricing ----
-- lualine
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "ayu_dark",
        component_separators = "⏽",
        section_separators = { left = "", right = "" },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            { "branch", separator = "" },
            "diff",
        },
        lualine_c = {
            "filename",
            {
                "diagnostics",
                sources = { "nvim_lsp" },
                symbols = { error = "", warn = "", info = "", hint = "" },
            },
        },
        lualine_x = {
            "filetype",
            {
                "fileformat",
                icons_enabled = true,
                symbols = {
                    unix = "LF",
                    dos = "CRLF",
                    mac = "CR",
                },
            },
            "encoding",
        },
        lualine_y = {
            "progress",
        },
        lualine_z = {
            "location",
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { "nvim-tree" },
})
-- bufferline-nvim
require("bufferline").setup({
    options = {
        close_command = function(bufnum)
            require("bufdelete").bufdelete(bufnum, false)
        end,
        right_mouse_command = "vertical sbuffer %d",
        indicator = {
            icon = "▎",
            style = "icon",
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        separator_style = "thin",
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "left" } },
        sort_by = "extension",
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = true,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = ""
            for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and "" or (e == "warning" and "" or "")
                if sym ~= "" then
                    s = s .. " " .. n .. sym
                end
            end
            return s
        end,
        numbers = function(opts)
            return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
    },
})
nnoremap("<leader>bn", "<cmd>BufferLineCycleNext<CR>")
nnoremap("<leader>bm", "<cmd>BufferLineCyclePrev<CR>")
nnoremap("<leader>bv", "<cmd>BufferLinePick<CR>")
nnoremap("<leader>bbn", "<cmd>BufferLineMoveNext<CR>")
nnoremap("<leader>bbm", "<cmd>BufferLineMovePrev<CR>")
nnoremap("<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>")
nnoremap("<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>")
nnoremap("<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>")
nnoremap("<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>")
nnoremap("<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>")
nnoremap("<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>")
nnoremap("<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>")
nnoremap("<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>")
nnoremap("<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>")

---- Language Overrides ----
-- nix
vim.cmd("autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2")
-- c
vim.g.c_syntax_for_h = 1

---- LSP Config ----
local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local save_format = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end
end
local default_on_attach = function(client)
    save_format(client)
end
nnoremap("<leader>u", "<cmd>lua vim.lsp.buf.format()<CR>")

null_ls.setup({
    diagnostics_format = "[#{m}] #{s} (#{c})",
    debounce = 250,
    default_timeout = 5000,
    sources = {
        null_ls.builtins.formatting.alejandra,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.stylua,
    },
    on_attach = default_on_attach,
})

-- lspkind
local lspkind = require("lspkind")
lspkind.init()

-- trouble
require("trouble").setup({})
nnoremap("<leader>xx", "<cmd>TroubleToggle<CR>")
nnoremap("<leader>xw", "<cmd>TroubleToggle worskpace_diagnostics<CR>")
nnoremap("<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>")
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
nnoremap("<leader>lk", "<cmd>lua require('lspsaga.diagnostic').show_cursor_diagnostics()<CR>")
nnoremap("<leader>ca", "<cmd>lua require('lspsaga.codeaction').code_action()<CR>")

--- setup language servers ---
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- zig
lspconfig.zls.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- nix
lspconfig.nil_ls.setup({
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
require("rust-tools").inlay_hints.enable()
-- python
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
lspconfig.sumneko_lua.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = runtime_path,
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
-- java
lspconfig.jdtls.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
    cmd = { "jdt-language-server", "-data", "/home/woze/.cache/jdtls/workspace" },
    init_options = {
        workspace = "/home/woze/.cache/jdtls/workspace",
    },
})
-- bash
lspconfig.bashls.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- clangd
lspconfig.clangd.setup({
    capabilities = capabilities,
})
-- deno
lspconfig.denols.setup({
    capabilities = capabilities,
    init_options = {
        lint = true,
    },
})
-- html
lspconfig.html.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
-- verilog
lspconfig.svls.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})
lspconfig.verible.setup({
    capabilities = capabilities,
    on_attach = default_on_attach,
})

---- Treesitter Config ----
local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")
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
            scope_incremental = "grb",
        },
    },
    autotag = {
        enable = true,
    },
    ensure_installed = {},
    parser_install_dir = parser_install_dir,
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
nnoremap("<leader>flt", "<cmd>Telescope lsp_type_definitions<CR>")
nnoremap("<leader>fld", "<cmd>Telescope lsp_definitions<CR>")
nnoremap("<leader>fs", "<cmd>Telescope treesitter<CR>")

---- nvim-autopairs Config ----
require("nvim-autopairs").setup({})

---- Copilot Config ----
-- require("copilot").setup({
--     cmp = { enabled = true },
--     panel = { enabled = true },
-- })

---- nvim-cmp Config ----
local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
        return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
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
        { name = "copilot" },
        { name = "vsnip" },
        { name = "treesitter" },
        { name = "path" },
        { name = "crates" },
        { name = "buffer" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable,
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping.confirm({
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() and has_words_before() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#available"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    }),
    completion = {
        completeopt = "menu,menuone,noinsert",
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind

            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                vsnip = "[VSnip]",
                treesitter = "[TS]",
                path = "[Path]",
                crates = "[Crates]",
                buffer = "[Buffer]",
                copilot = "[Copilot]",
            })[entry.source.name]

            return vim_item
        end,
    },
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { text = "" } }))

---- indent-blankline Config ----
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        vim.defer_fn(function()
            vim.cmd("highlight IndentBlankline guifg=#151510 gui=nocombine")
        end, 100)
    end,
})
require("indent_blankline").setup({
    char_highlight_list = { "IndentBlankline" },
    show_current_context = true,
    show_current_context_start = true,
    show_trailing_blankline_indent = false,
})

---- nvim-cursorline Config ----
vim.g.cursorline_timeout = 500

---- comment-nvim Config ----
require("Comment").setup({})

---- nvim-tree-lua Config ----
require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    open_on_tab = false,
    open_on_setup = false,
    diagnostics = { enable = true },
    view = { width = 40, side = "left" },
    git = { enable = true, ignore = false },
    filters = {
        dotfiles = false,
        custom = {
            ".git",
            "node_modules",
            ".cache",
            "zig-cache",
        },
    },
    renderer = {
        indent_markers = {
            enable = true,
        },
        group_empty = true,
        add_trailing = true,
    },
})
nnoremap("<C-n>", "<cmd>NvimTreeToggle<CR>")
nnoremap("<leader>tr", "<cmd>NvimTreeRefresh<CR>")

---- glow-nvim Config ----
vim.cmd("autocmd FileType markdown noremap <leader>p <cmd>Glow<CR>")
