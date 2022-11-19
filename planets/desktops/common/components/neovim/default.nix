{
  config,
  pkgs,
  lib,
  ...
}: let
  pluginGit = repo: rev: ref:
    pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "${lib.strings.sanitizeDerivationName repo}-${rev}";
      version = rev;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit ref;
        inherit rev;
      };
    };
in {
  programs.neovim = {
    enable = true;
    withNodeJs = false;

    extraConfig = builtins.concatStringsSep "\n" [
      ''
        lua << EOF
        ${lib.strings.fileContents ./util.lua}
        ${lib.strings.fileContents ./init.lua}
        EOF
      ''
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
      jdt-language-server
      nil
      nodePackages.bash-language-server
      nodePackages.pyright
      rust-analyzer
      rustc
      rustfmt
      sumneko-lua-language-server
      svls
      verible
      zls.zls

      # formatters
      alejandra
      stylua

      # need node 16 for copilot
      nodejs-16_x
      nodePackages.vscode-langservers-extracted
    ];

    plugins = with pkgs.vimPlugins; [
      # ricing
      (pluginGit "nekonako/xresources-nvim" "745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582" "master")
      bufdelete-nvim
      bufferline-nvim
      lualine-nvim
      nvim-base16

      # libraries
      plenary-nvim
      sqlite-lua
      # lsp
      lspkind-nvim
      lspsaga-nvim
      null-ls-nvim
      nvim-code-action-menu
      nvim-lightbulb
      nvim-lspconfig
      trouble-nvim
      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-ts-autotag
      # telescope
      (pluginGit "nvim-telescope/telescope-ui-select.nvim" "d02a3d3a6b3f6b933c43a28668ae18f78846d3aa" "master")
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
      indent-blankline-nvim
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
      (pluginGit "DingDean/wgsl.vim" "fbe8f0dd179aec8525d6c93bb992e409b0e4e0ee" "main")
      (pluginGit "elkowar/yuck.vim" "6dc3da77c53820c32648cf67cbdbdfb6994f4e08" "master")
      (pluginGit "lluchs/vim-wren" "713705a23bdb94ff6c29866ff4a9db089cbc2dab" "master")
      (pluginGit "stefanos82/nelua.vim" "ff0a733a586ef0b48cda4999170ed4ca1653a144" "main")
      zig-vim

      # lsp language additionals
      crates-nvim
      rust-tools-nvim

      # copilot
      # (pluginGit "zbirenbaum/copilot.lua" "5fbe531eb53f6a782d0fed7166f8cec23d606e84" "master")
      # (pluginGit "zbirenbaum/copilot-cmp" "4a8909fd63dff71001b22a287daa3830e447de70" "master")
      (pluginGit "github/copilot.vim" "5a411d19ce7334ab10ba12516743fc25dad363fa" "release")
      cmp-copilot

      # firenvim
      (pluginGit "glacambre/firenvim" "2f0ee858c3eb5c9d306523cc054047eda2e6a3a2" "master")
    ];
  };
}
