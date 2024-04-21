require("impatient")

---- General Config ----
-- utf-8 encoding
vim.opt.encoding = "utf-8"
-- enable mouse
vim.opt.mouse = "a"
-- enable lists
vim.opt.list = true
-- set indent width
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
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
-- lazy redraw
vim.opt.lazyredraw = true
-- disable bells
vim.opt.errorbells = false
vim.opt.visualbell = false
-- use system clipboard
vim.cmd("set clipboard+=unnamedplus")
-- full colors
vim.opt.termguicolors = true
-- map space to leader key
vim.cmd('let mapleader=" "')
vim.cmd('let maplocalleader=" "')
nnoremap("<space>", "<nop>")

-- diable some built-in plugins
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

---- Keybindings ----
nnoremap("<leader>tt", "<cmd>tabnew<CR>")
nnoremap("<leader>tm", "<cmd>tabp<CR>")
nnoremap("<leader>tn", "<cmd>tabn<CR>")
nnoremap("<leader>bd", "<cmd>lua require('bufdelete').bufdelete(0, false)<CR>")
nnoremap("//", "<cmd>noh<CR>")
nnoremap("<C-k>", "<cmd>wincmd k<CR>")
nnoremap("<C-j>", "<cmd>wincmd j<CR>")
nnoremap("<C-h>", "<cmd>wincmd h<CR>")
nnoremap("<C-l>", "<cmd>wincmd l<CR>")

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
		buffer_close_icon = "",
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
-- c & cpp
vim.g.c_syntax_for_h = 1
-- endron
vim.filetype.add({
	extension = {
		["edr"] = "endron",
	},
})

---- LSP Config ----
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local save_format = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				-- vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end
local default_on_attach = function(client)
	save_format(client)
end
nnoremap("<leader>u", "<cmd>lua vim.lsp.buf.format()<CR>")

lazy_require("null-ls", function(null_ls)
	return {
		diagnostics_format = "[#{m}] #{s} (#{c})",
		debounce = 250,
		default_timeout = 5000,
		sources = {
			null_ls.builtins.formatting.alejandra,
			null_ls.builtins.formatting.black,
			null_ls.builtins.formatting.stylua,
		},
		on_attach = default_on_attach,
	}
end)

-- lspkind
local lspkind = require("lspkind")
lspkind.init()

-- trouble
lazy_require("trouble", {})
nnoremap("<leader>xx", "<cmd>TroubleToggle<CR>")
nnoremap("<leader>xw", "<cmd>TroubleToggle worskpace_diagnostics<CR>")
nnoremap("<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>")
nnoremap("<leader>xq", "<cmd>TroubleToggle quickfix<CR>")
nnoremap("<leader>xl", "<cmd>TroubleToggle loclist<CR>")
nnoremap("<leader>xr", "<cmd>TroubleToggle lsp_references<CR>")

-- lspsaga
lazy_require("lspsaga", {
	lightbulb = { enable = false },
})
nnoremap("<leader>lf", "<cmd>Lspsaga lsp_finder<CR>")
nnoremap("<leader>lh", "<cmd>Lspsaga hover_doc<CR>")
nnoremap("<leader>lr", "<cmd>Lspsaga rename<CR>")
nnoremap("<leader>lk", "<cmd>Lspsaga peek_definition<CR>")
nnoremap("<leader>lj", "<cmd>Lspsaga goto_definition<CR>")
nnoremap("<leader>ll", "<cmd>Lspsaga outline<CR>")
nnoremap("<leader>ca", "<cmd>Lspsaga code_action<CR>")

--- setup language servers ---
local lspconfig = require("lspconfig")
local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.util.default_config = vim.tbl_deep_extend("force", lspconfig.util.default_config, {
	capabilities = cmp_capabilities,
})

-- zig
lspconfig.zls.setup({
	on_attach = default_on_attach,
})
-- nix
lspconfig.nil_ls.setup({
	on_attach = default_on_attach,
})
-- lspconfig.nixd.setup({
--     on_attach = default_on_attach,
-- })
-- rust
lspconfig.rust_analyzer.setup({})
lazy_require("crates", {})
require("rust-tools").setup({
	server = {
		on_attach = default_on_attach,
	},
})
require("rust-tools").inlay_hints.enable()
-- python
lspconfig.pyright.setup({
	on_attach = default_on_attach,
})
-- lua
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
lspconfig.lua_ls.setup({
	on_attach = default_on_attach,
	settings = {
		Lua = {
			telemetry = {
				enable = false,
			},
			runtime = {
				version = "LuaJIT",
				path = runtime_path,
			},
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
-- java
lspconfig.jdtls.setup({
	on_attach = default_on_attach,
	cmd = { "jdtls", "-data", "/home/woze/.cache/jdtls/workspace" },
	init_options = {
		workspace = "/home/woze/.cache/jdtls/workspace",
	},
})
-- bash
lspconfig.bashls.setup({
	on_attach = default_on_attach,
})
-- clangd
lspconfig.clangd.setup({
	on_attach = default_on_attach,
})
-- deno
lspconfig.denols.setup({
	on_attach = default_on_attach,
	init_options = {
		lint = true,
	},
})
-- html
lspconfig.html.setup({
	on_attach = default_on_attach,
})
-- verilog
lspconfig.svls.setup({
	on_attach = default_on_attach,
})
lspconfig.verible.setup({
	on_attach = default_on_attach,
})
-- ltex
lspconfig.ltex.setup({
	on_attach = default_on_attach,
	settings = {
		ltex = {
			language = "en-US",
			filetypes = {
				"bib",
				"gitcommit",
				"markdown",
				"org",
				"plaintex",
				"rst",
				"rnoweb",
				"tex",
				"pandoc",
				"asciidoc",
			},
		},
	},
})
-- go
lspconfig.gopls.setup({
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
local treesitter_parsers = require("nvim-treesitter.parsers").get_parser_configs()
treesitter_parsers.endron = {
	install_info = {
		url = "~/projects/enqy/tree-sitter-endron",
		files = { "src/parser.c" },
	},
}
treesitter_parsers.hypr = {
	install_info = {
		url = "https://github.com/luckasRanarison/tree-sitter-hypr",
		files = { "src/parser.c" },
		branch = "master",
	},
	filetype = "hypr",
}
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
		frecency = {
			db_safe_mode = false,
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
nnoremap("<leader>fa", "<cmd>Telescope<CR>")
nnoremap("<leader>flsw", "<cmd>Telescope lsp_workspace_symbols<CR>")
nnoremap("<leader>flsd", "<cmd>Telescope lsp_document_symbols<CR>")
nnoremap("<leader>flr", "<cmd>Telescope lsp_references<CR>")
nnoremap("<leader>flt", "<cmd>Telescope lsp_type_definitions<CR>")
nnoremap("<leader>fld", "<cmd>Telescope lsp_definitions<CR>")
nnoremap("<leader>fs", "<cmd>Telescope treesitter<CR>")

---- nvim-autopairs Config ----
require("nvim-autopairs").setup({})

---- Copilot Config ----
-- lazy_require("copilot", {
--     panel = { enabled = false },
--     suggestion = { enabled = false },
--     filetypes = {
--         markdown = true,
--     },
-- })
-- lazy_require("copilot_cmp", {})
vim.g.copilot_no_tab_map = true

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
		{ name = "nvim_lsp", group_index = 2 },
		{ name = "path", group_index = 2 },
		{ name = "copilot", group_index = 2 },
		{ name = "treesitter", group_index = 2 },
		{ name = "vsnip", group_index = 2 },
		{ name = "crates", group_index = 2 },
		{ name = "buffer", group_index = 2 },
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4)),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete()),
		["<C-y>"] = cmp.config.disable,
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({
			-- behavior = cmp.ConfirmBehavior.Replace,
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
		end),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn["vsnip#available"](-1) == 1 then
				feedkey("<Plug>(vsnip-jump-prev)", "")
			end
		end),
	}),
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	formatting = {
		format = function(entry, vim_item)
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
local ibl_hooks = require("ibl.hooks")
local ibl_highlight = {
	"RainbowRed",
	"RainbowYellow",
	"RainbowBlue",
	"RainbowOrange",
	"RainbowGreen",
	"RainbowViolet",
	"RainbowCyan",
}
vim.g.rainbow_delimiters = { highlight = ibl_highlight }
ibl_hooks.register(ibl_hooks.type.HIGHLIGHT_SETUP, function()
	vim.api.nvim_set_hl(0, "IndentBlankline", { fg = "#151510" })
	vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#a52e4d" })
	vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#996f06" })
	vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#006fc1" })
	vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#d8272a" })
	vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#228039" })
	vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#aa3c9f" })
	vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#33b3f4" })
end)
require("ibl").setup({
	indent = {
		highlight = {
			"IndentBlankline",
		},
		char = "▎",
		tab_char = "▎",
	},
	scope = {
		highlight = ibl_highlight,
	},
})
ibl_hooks.register(ibl_hooks.type.SCOPE_HIGHLIGHT, ibl_hooks.builtin.scope_highlight_from_extmark)

---- nvim-cursorline Config ----
vim.g.cursorline_timeout = 500

---- comment-nvim Config ----
require("Comment").setup({})

---- nvim-tree-lua Config ----
lazy_require("nvim-tree", {
	diagnostics = { enable = true },
	view = {
		adaptive_size = false,
		width = 35,
		preserve_window_proportions = true,
		side = "left",
	},
	git = { ignore = false },
	renderer = {
		indent_markers = { enable = true },
		add_trailing = true,
	},
})
nnoremap("<C-n>", "<cmd>NvimTreeToggle<CR>")
nnoremap("<leader>tr", "<cmd>NvimTreeRefresh<CR>")

---- glow-nvim Config ----
vim.cmd("autocmd FileType markdown noremap <leader>p <cmd>Glow<CR>")
