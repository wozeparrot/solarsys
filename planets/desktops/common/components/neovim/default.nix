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
    };
in
{
  home.packages = with pkgs; [ neovide ];

  programs.neovim = {
    enable = true;
    withNodeJs = true;

    extraLuaConfig = builtins.concatStringsSep "\n" [
      (
        let
          colors = config.lib.stylix.colors.withHashtag;
        in
        ''
          vim.g.termguicolors = true;
          require("base16-colorscheme").setup({
            base00 = "${colors.base00}",
            base01 = "${colors.base01}",
            base02 = "${colors.base02}",
            base03 = "${colors.base03}",
            base04 = "${colors.base04}",
            base05 = "${colors.base05}",
            base06 = "${colors.base06}",
            base07 = "${colors.base07}",
            base08 = "${colors.base08}",
            base09 = "${colors.base09}",
            base0A = "${colors.base0A}",
            base0B = "${colors.base0B}",
            base0C = "${colors.base0C}",
            base0D = "${colors.base0D}",
            base0E = "${colors.base0E}",
            base0F = "${colors.base0F}",
          });
          vim.g.neovide_transparency = 0.9;
        ''
      )
      (lib.strings.fileContents ./util.lua)
      (lib.strings.fileContents ./init.lua)
    ];

    extraPackages = with pkgs; [
      # libraries
      sqlite
      # treesitter
      gcc
      tree-sitter
      # telescope
      fd
      ripgrep
      # glow
      glow

      # lsp language additionals
      black
      cargo
      clang-tools
      deno
      go
      gopls
      jdt-language-server
      ltex-ls
      lua-language-server
      nil
      nixd.nixd
      nodePackages.bash-language-server
      basedpyright
      rust-analyzer
      rustc
      rustfmt
      svls
      verible
      zls.zls

      # formatters
      nixfmt-rfc-style
      stylua

      nodePackages.vscode-langservers-extracted
    ];

    plugins = with pkgs.vimPlugins; [
      # ricing
      bufdelete-nvim
      bufferline-nvim
      lualine-nvim
      base16-nvim

      # util
      nvim-lastplace

      # libraries
      plenary-nvim
      sqlite-lua

      # lsp
      lspkind-nvim
      lspsaga-nvim
      none-ls-nvim
      nvim-code-action-menu
      nvim-lspconfig
      trouble-nvim

      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-ts-autotag

      # telescope
      (pluginGit "nvim-telescope/telescope-ui-select.nvim" "6e51d7da30bd139a6950adf2a47fda6df9fa06d2"
        "master"
      )
      telescope-frecency-nvim
      telescope-fzf-native-nvim
      telescope-nvim

      # nvim-autopairs
      nvim-autopairs

      # vim-vsnip
      friendly-snippets
      vim-vsnip

      # nvim-cmp
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp-treesitter
      cmp-vsnip
      nvim-cmp

      # indent-blankline
      (pluginGit "lukas-reineke/indent-blankline.nvim" "65e20ab94a26d0e14acac5049b8641336819dfc7"
        "master"
      )
      rainbow-delimiters-nvim

      # nvim-cursorline
      nvim-cursorline

      # nvim-web-devicons
      nvim-web-devicons

      # comment-nvim
      comment-nvim

      # nvim-tree-lua
      nvim-tree-lua

      # glow
      glow-nvim

      # language support
      (pluginGit "DingDean/wgsl.vim" "fdf91e11243266dfe923fc08c2fc9749429bc5aa" "main")
      (pluginGit "avivbeeri/vim-wren" "2514d32c8e476384f3df81bd2cd369908d85bcfe" "fixedStatic")
      (pluginGit "elkowar/yuck.vim" "9b5e0370f70cc30383e1dabd6c215475915fe5c3" "master")
      (pluginGit "stefanos82/nelua.vim" "ff0a733a586ef0b48cda4999170ed4ca1653a144" "main")
      zig-vim
      vim-opencl

      # lsp language additionals
      crates-nvim
      rust-tools-nvim

      # copilot
      (pluginGit "zbirenbaum/copilot.lua" "86537b286f18783f8b67bccd78a4ef4345679625" "master")
      (pluginGit "zbirenbaum/copilot-cmp" "b6e5286b3d74b04256d0a7e3bd2908eabec34b44" "master")

      # firenvim
      (pluginGit "glacambre/firenvim" "c6e37476ab3b58cf01ababfe80ec9335798e70e5" "master")
    ];
  };
}
