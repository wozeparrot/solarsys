{
  config,
  pkgs,
  lib,
  ...
}:
let
  pluginGit =
    repo: rev: ref:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}-${rev}";
      version = rev;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit ref;
        inherit rev;
      };
      doCheck = false;
    };
  c = config.lib.stylix.colors.withHashtag;
in
{
  home.packages = with pkgs; [ neovide ];

  programs.nixvim = {
    enable = true;
    withNodeJs = true;
    luaLoader.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      neovide_transparency = 0.9;
      c_syntax_for_h = 1;
    };

    opts = {
      encoding = "utf-8";
      mouse = "a";
      list = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      cmdheight = 1;
      updatetime = 300;
      tm = 500;
      shortmess = "filnxtToOFc";
      hidden = true;
      splitbelow = true;
      splitright = true;
      undofile = true;
      signcolumn = "yes";
      number = true;
      relativenumber = true;
      lazyredraw = true;
      errorbells = false;
      visualbell = false;
      clipboard = "unnamedplus";
      termguicolors = true;
      # treesitter folding
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
    };

    keymaps = [
      # -- General --
      {
        mode = "n";
        key = "<space>";
        action = "<nop>";
      }
      {
        mode = "n";
        key = "//";
        action = "<cmd>noh<CR>";
        options.silent = true;
      }
      {
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
        options.silent = true;
      }

      # -- Tabs --
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>tabnew<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>tm";
        action = "<cmd>tabp<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>tabn<CR>";
        options.silent = true;
      }

      # -- Buffers --
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() Snacks.bufdelete() end";
        options = {
          silent = true;
          desc = "Delete buffer";
        };
      }
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>bv";
        action = "<cmd>BufferLinePick<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>bbn";
        action = "<cmd>BufferLineMoveNext<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>bbm";
        action = "<cmd>BufferLineMovePrev<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>1";
        action = "<cmd>BufferLineGoToBuffer 1<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>2";
        action = "<cmd>BufferLineGoToBuffer 2<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>3";
        action = "<cmd>BufferLineGoToBuffer 3<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>4";
        action = "<cmd>BufferLineGoToBuffer 4<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>5";
        action = "<cmd>BufferLineGoToBuffer 5<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>6";
        action = "<cmd>BufferLineGoToBuffer 6<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>7";
        action = "<cmd>BufferLineGoToBuffer 7<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>8";
        action = "<cmd>BufferLineGoToBuffer 8<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>9";
        action = "<cmd>BufferLineGoToBuffer 9<CR>";
        options.silent = true;
      }

      # -- Windows --
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>wincmd k<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>wincmd j<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>wincmd h<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<cmd>wincmd l<CR>";
        options.silent = true;
      }

      # -- Formatting (conform) --
      {
        mode = "n";
        key = "<leader>u";
        action.__raw = ''function() require("conform").format({ async = true, lsp_fallback = true }) end'';
        options.silent = true;
      }

      # -- Telescope --
      {
        mode = "n";
        key = "<leader>fd";
        action = "<cmd>Telescope find_files<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope frecency<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fvcw";
        action = "<cmd>Telescope git_commits<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fvcb";
        action = "<cmd>Telescope git_bcommits<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fvb";
        action = "<cmd>Telescope git_branches<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fvs";
        action = "<cmd>Telescope git_status<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fa";
        action = "<cmd>Telescope<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>flsw";
        action = "<cmd>Telescope lsp_workspace_symbols<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>flsd";
        action = "<cmd>Telescope lsp_document_symbols<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>flr";
        action = "<cmd>Telescope lsp_references<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>flt";
        action = "<cmd>Telescope lsp_type_definitions<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fld";
        action = "<cmd>Telescope lsp_definitions<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<cmd>Telescope treesitter<CR>";
        options.silent = true;
      }

      # -- Lspsaga --
      {
        mode = "n";
        key = "<leader>lf";
        action = "<cmd>Lspsaga finder<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>lh";
        action = "<cmd>Lspsaga hover_doc<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>lr";
        action = "<cmd>Lspsaga rename<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>lk";
        action = "<cmd>Lspsaga peek_definition<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>lj";
        action = "<cmd>Lspsaga goto_definition<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>ll";
        action = "<cmd>Lspsaga outline<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>Lspsaga code_action<CR>";
        options.silent = true;
      }

      # -- Trouble --
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        options.silent = true;
      }

      # -- nvim-tree --
      {
        mode = "n";
        key = "<C-n>";
        action = "<cmd>NvimTreeToggle<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>tr";
        action = "<cmd>NvimTreeRefresh<CR>";
        options.silent = true;
      }

      # -- Git --
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = "function() Snacks.lazygit() end";
        options = {
          silent = true;
          desc = "LazyGit";
        };
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
        options = {
          silent = true;
          desc = "Toggle blame";
        };
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<CR>";
        options = {
          silent = true;
          desc = "Preview hunk";
        };
      }

      # -- Terminal --
      {
        mode = "n";
        key = "<C-/>";
        action.__raw = "function() Snacks.terminal() end";
        options = {
          silent = true;
          desc = "Terminal";
        };
      }
      {
        mode = "t";
        key = "<C-/>";
        action.__raw = "function() Snacks.terminal() end";
        options = {
          silent = true;
          desc = "Terminal";
        };
      }

      # -- Todos --
      {
        mode = "n";
        key = "<leader>ft";
        action = "<cmd>TodoTelescope<CR>";
        options = {
          silent = true;
          desc = "Find todos";
        };
      }
      {
        mode = "n";
        key = "<leader>xt";
        action = "<cmd>Trouble todo toggle<CR>";
        options = {
          silent = true;
          desc = "Todos (Trouble)";
        };
      }

      # -- Word references --
      {
        mode = "n";
        key = "]]";
        action.__raw = "function() Snacks.words.jump(vim.v.count1) end";
        options = {
          silent = true;
          desc = "Next reference";
        };
      }
      {
        mode = "n";
        key = "[[";
        action.__raw = "function() Snacks.words.jump(-vim.v.count1) end";
        options = {
          silent = true;
          desc = "Prev reference";
        };
      }

      # -- Sessions --
      {
        mode = "n";
        key = "<leader>qs";
        action.__raw = ''function() require("persistence").load() end'';
        options = {
          silent = true;
          desc = "Restore session";
        };
      }
      {
        mode = "n";
        key = "<leader>ql";
        action.__raw = ''function() require("persistence").select() end'';
        options = {
          silent = true;
          desc = "List sessions";
        };
      }
    ];

    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
      }
      {
        event = "FileType";
        pattern = [
          "c"
          "cpp"
        ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2";
      }
      {
        event = "FileType";
        pattern = "python";
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 cc=150";
      }
      {
        event = "FileType";
        pattern = "markdown";
        command = "noremap <buffer> <leader>p <cmd>Glow<CR>";
      }
      {
        event = "User";
        pattern = "PersistenceSavePre";
        callback.__raw = ''
          function()
            local nvim_tree_ok, api = pcall(require, "nvim-tree.api")
            if nvim_tree_ok then api.tree.close() end
          end
        '';
      }
    ];

    filetype.extension = {
      edr = "endron";
    };

    diagnostic.settings = {
      virtual_text = true;
      underline = true;
      signs = true;
      update_in_insert = false;
      severity_sort = true;
    };

    extraPackages = with pkgs; [
      sqlite
      fd
      ripgrep
      glow
      black
      cargo
      deno
      go
      jdt-language-server
      rustc
      rustfmt
      nixfmt
      stylua
      verible
      lazygit
    ];

    plugins = {
      # -- UI / Ricing --
      lualine = {
        enable = true;
        settings = {
          options = {
            icons_enabled = true;
            component_separators = "⏽";
            section_separators = {
              left = "";
              right = "";
            };
            theme = {
              normal = {
                a = { bg = c.base02; fg = c.base07; };
                b = { bg = c.base01; fg = c.base04; };
                c = { bg = c.base01; fg = c.base03; };
              };
              insert = {
                a = { bg = c.base0B; fg = c.base00; };
              };
              visual = {
                a = { bg = c.base0E; fg = c.base00; };
              };
              replace = {
                a = { bg = c.base08; fg = c.base00; };
              };
              command = {
                a = { bg = c.base0D; fg = c.base00; };
              };
              inactive = {
                a = { bg = c.base01; fg = c.base02; };
                b = { bg = c.base01; fg = c.base02; };
                c = { bg = c.base01; fg = c.base02; };
              };
            };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              {
                __unkeyed-1 = "branch";
                separator = "";
              }
              "diff"
            ];
            lualine_c = [
              "filename"
              {
                __unkeyed-1 = "diagnostics";
                sources = [ "nvim_lsp" ];
                symbols = {
                  error = "";
                  warn = "";
                  info = "";
                  hint = "";
                };
              }
            ];
            lualine_x = [
              "filetype"
              {
                __unkeyed-1 = "fileformat";
                icons_enabled = true;
                symbols = {
                  unix = "LF";
                  dos = "CRLF";
                  mac = "CR";
                };
              }
              "encoding"
            ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
          inactive_sections = {
            lualine_a = [ ];
            lualine_b = [ ];
            lualine_c = [ "filename" ];
            lualine_x = [ "location" ];
            lualine_y = [ ];
            lualine_z = [ ];
          };
          tabline = { };
          extensions = [ "nvim-tree" ];
        };
      };

      bufferline = {
        enable = true;
        settings = {
          options = {
            close_command.__raw = "function(bufnum) Snacks.bufdelete(bufnum) end";
            right_mouse_command = "vertical sbuffer %d";
            indicator.style = "underline";
            hover = {
              enable = true;
              delay = 500;
              reveal = [ "close" ];
            };
            buffer_close_icon = "";
            modified_icon = "●";
            close_icon = "";
            left_trunc_marker = "";
            right_trunc_marker = "";
            separator_style = "thin";
            max_name_length = 18;
            max_prefix_length = 15;
            tab_size = 18;
            show_buffer_icons = true;
            show_buffer_close_icons = true;
            show_close_icon = true;
            show_tab_indicators = true;
            persist_buffer_sort = true;
            enforce_regular_tabs = true;
            always_show_bufferline = true;
            offsets = [
              {
                filetype = "NvimTree";
                text = "File Explorer";
                text_align = "left";
              }
            ];
            sort_by = "insert_at_end";
            diagnostics = "nvim_lsp";
            diagnostics_indicator.__raw = ''
              function(count, level, diagnostics_dict, context)
                local s = ""
                for e, n in pairs(diagnostics_dict) do
                  local sym = e == "error" and "" or (e == "warning" and "" or "")
                  if sym ~= "" then
                    s = s .. " " .. n .. sym
                  end
                end
                return s
              end
            '';
            numbers.__raw = ''
              function(opts)
                return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
              end
            '';
          };
        };
      };

      web-devicons.enable = true;

      snacks = {
        enable = true;
        settings = {
          bigfile.enabled = true;
          bufdelete.enabled = true;
          indent = {
            enabled = true;
            indent.char = "│";
            scope = {
              enabled = true;
              only_current = true;
            };
          };
          words = {
            enabled = true;
            debounce = 500;
          };
          notifier = {
            enabled = true;
            timeout = 3000;
          };
          quickfile.enabled = true;
          statuscolumn.enabled = true;
          scroll.enabled = true;
          dashboard = {
            enabled = true;
            preset.keys = [
              { key = "f"; desc = "Find File"; action = ":Telescope find_files"; }
              { key = "g"; desc = "Live Grep"; action = ":Telescope live_grep"; }
              { key = "r"; desc = "Recent Files"; action = ":Telescope oldfiles"; }
              { key = "s"; desc = "Restore Session"; action.__raw = ''function() require("persistence").load() end''; }
              { key = "q"; desc = "Quit"; action = ":qa"; }
            ];
            sections = [
              { section = "header"; }
              {
                section = "keys";
                gap = 1;
                padding = 1;
              }
              {
                title = "Recent (cwd)";
                padding = 1;
              }
              {
                section = "recent_files";
                cwd = true;
                limit = 5;
                padding = 1;
              }
              {
                title = "Recent (global)";
                padding = 1;
              }
              {
                section = "recent_files";
                limit = 5;
                padding = 1;
              }
              {
                icon = " ";
                title = "Sessions";
                section = "projects";
                action.__raw = ''
                  function(item)
                    local dir = item.dir or item.cwd or item.file or (type(item) == "string" and item) or item[1]
                    if dir then
                      vim.cmd("cd " .. dir)
                    end
                    require("persistence").load()
                  end
                '';
                padding = 1;
              }
            ];
          };
          input.enabled = true;
          terminal.enabled = true;
          git.enabled = true;
          rename.enabled = true;
          lazygit = {
            enabled = true;
            configure = true;
          };
        };
      };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "│";
            change.text = "│";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
            untracked.text = "┆";
          };
          current_line_blame = false;
          current_line_blame_opts = {
            virt_text = true;
            virt_text_pos = "eol";
            delay = 500;
          };
          on_attach.__raw = ''
            function(bufnr)
              local gs = package.loaded.gitsigns
              vim.keymap.set('n', ']h', function()
                if vim.wo.diff then return ']h' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
              end, {expr=true, buffer=bufnr, desc="Next hunk"})
              vim.keymap.set('n', '[h', function()
                if vim.wo.diff then return '[h' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
              end, {expr=true, buffer=bufnr, desc="Previous hunk"})
            end
          '';
        };
      };

      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>l";
            group = "LSP";
          }
          {
            __unkeyed-1 = "<leader>b";
            group = "Buffer";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Tab/Tree";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "Diagnostics";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
          }
          {
            __unkeyed-1 = "<leader>q";
            group = "Session";
          }
        ];
      };

      todo-comments.enable = true;

      flash = {
        enable = true;
        settings.modes.char.enabled = true;
      };

      persistence.enable = true;

      # -- Navigation --
      telescope = {
        enable = true;
        settings = {
          defaults = {
            vimgrep_arguments = [
              "rg"
              "--color=never"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
              "--smart-case"
            ];
            pickers = {
              find_command = [ "fd" ];
            };
          };
          extensions = { };
        };
        extensions = {
          fzf-native = {
            enable = true;
            settings = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
              case_mode = "smart_case";
            };
          };
          frecency = {
            enable = true;
            settings.db_safe_mode = false;
          };
          ui-select.enable = true;
        };
      };

      nvim-tree = {
        enable = true;
        settings = {
          diagnostics.enable = true;
          view = {
            adaptive_size = false;
            width = 35;
            preserve_window_proportions = true;
            side = "left";
          };
          git.ignore = false;
          renderer = {
            indent_markers.enable = true;
            add_trailing = true;
          };
        };
      };

      lastplace = {
        enable = true;
        settings = {
          lastplace_ignore_buftype = [
            "quickfix"
            "nofile"
            "help"
          ];
          lastplace_ignore_filetype = [
            "gitcommit"
            "gitrebase"
            "svn"
            "hgcommit"
          ];
        };
      };

      # -- LSP --
      lsp = {
        enable = true;
        servers = {
          zls.enable = true;
          nil_ls.enable = true;
          pyright.enable = true;
          lua_ls = {
            enable = true;
            settings = {
              telemetry.enable = false;
              runtime.version = "LuaJIT";
              diagnostics.globals = [ "vim" ];
            };
          };
          jdtls = {
            enable = true;
            cmd = [
              "jdtls"
              "-data"
              "/home/woze/.cache/jdtls/workspace"
            ];
            extraOptions.init_options.workspace = "/home/woze/.cache/jdtls/workspace";
          };
          bashls.enable = true;
          clangd.enable = true;
          denols = {
            enable = true;
            extraOptions.init_options.lint = true;
          };
          html.enable = true;
          svls.enable = true;
          gopls.enable = true;
        };
      };

      lspsaga = {
        enable = true;
        settings.lightbulb.enable = false;
      };

      trouble.enable = true;
      rustaceanvim.enable = true;
      crates.enable = true;

      # -- Formatting (replaces none-ls) --
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            python = [ "black" ];
            lua = [ "stylua" ];
          };
        };
      };

      # -- Completion (replaces nvim-cmp + vim-vsnip) --
      blink-cmp = {
        enable = true;
        settings = {
          sources = {
            default = [
              "lsp"
              "path"
              "buffer"
              "copilot"
              "snippets"
            ];
            providers = {
              copilot = {
                name = "copilot";
                module = "blink-cmp-copilot";
                score_offset = 100;
                async = true;
              };
            };
          };
          keymap = {
            "<Tab>" = [
              "select_next"
              "snippet_forward"
              "fallback"
            ];
            "<S-Tab>" = [
              "select_prev"
              "snippet_backward"
              "fallback"
            ];
            "<CR>" = [
              "accept"
              "fallback"
            ];
            "<C-Space>" = [
              "show"
              "show_documentation"
              "hide_documentation"
            ];
            "<C-d>" = [
              "scroll_documentation_up"
              "fallback"
            ];
            "<C-f>" = [
              "scroll_documentation_down"
              "fallback"
            ];
          };
          completion = {
            menu.auto_show = true;
          };
        };
      };
      friendly-snippets.enable = true;

      # -- Treesitter --
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [ ];
          highlight.enable = true;
        };
      };

      # -- Editing --
      nvim-autopairs.enable = true;
      nvim-ts-autotag.enable = true;

      # -- AI --
      copilot-lua = {
        enable = true;
        settings = {
          panel.enabled = false;
          suggestion.enabled = false;
          filetypes = {
            markdown = true;
            gitcommit = true;
            yaml = true;
          };
        };
      };

      # -- Markdown --
      glow.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      blink-cmp-copilot
      vim-opencl
      wgsl-vim
      yuck-vim
      zig-vim
      (pluginGit "glacambre/firenvim" "4d2eef5fd2a7af0e91b76f1a9715228548316125" "master")
      (pluginGit "xiyaowong/virtcolumn.nvim" "4d385b4aa42aa3af6fa2cb8527462fa4badbd163" "main")
      (pluginGit "avivbeeri/vim-wren" "2514d32c8e476384f3df81bd2cd369908d85bcfe" "fixedStatic")
      (pluginGit "stefanos82/nelua.vim" "ff0a733a586ef0b48cda4999170ed4ca1653a144" "main")
      (pluginGit "NlGHT/vim-eel" "7c1357b098629cf952ff7b2b6900295093c1bbeb" "master")
    ];

    extraConfigLua = ''
      -- verible LSP (no nixvim module)
      vim.lsp.config("verible", {
        cmd = { "verible-verilog-ls", "--rules_config_search" },
      })
      vim.lsp.enable("verible")

      -- Dim indent guides so they don't overpower the code
      vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "${c.base02}" })

      -- Darken statusline and bufferline backgrounds to base01
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "${c.base01}", fg = "${c.base03}" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "${c.base01}", fg = "${c.base02}" })
      vim.api.nvim_set_hl(0, "TabLine", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "TabLineSel", { bg = "${c.base01}" })
      -- Bufferline background overrides
      vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = "${c.base01}", fg = "${c.base02}" })
      vim.api.nvim_set_hl(0, "BufferLineBuffer", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { bg = "${c.base01}", fg = "${c.base03}" })
      vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { bg = "${c.base01}", fg = "${c.base05}", bold = true })
      vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = "${c.base01}", fg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { bg = "${c.base01}", fg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { bg = "${c.base01}", fg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineTab", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineTabClose", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "BufferLineOffsetSeparator", { bg = "${c.base01}", fg = "${c.base01}" })
      -- Winbar / WinSeparator
      vim.api.nvim_set_hl(0, "WinBar", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "WinBarNC", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "WinSeparator", { bg = "${c.base00}", fg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "SagaWinbarSep", { bg = "${c.base01}", fg = "${c.base02}" })
      vim.api.nvim_set_hl(0, "SagaWinbar", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "SagaWinbarFolder", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "SagaWinbarFolderName", { bg = "${c.base01}" })
      vim.api.nvim_set_hl(0, "SagaWinbarFileName", { bg = "${c.base01}" })
    '';
  };
}
