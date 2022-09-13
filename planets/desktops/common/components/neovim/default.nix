{ config, pkgs, lib, ... }:
let
  pluginGit = repo: rev: ref: pkgs.vimUtils.buildVimPluginFrom2Nix {
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
      tree-sitter
      gcc
      # telescope
      ripgrep
      fd
      # glow
      glow

      # lsp language additionals
      ((zls.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "zigtools";
          repo = "zls";
          rev = "d72cac04ab0d048e0014294fd125a0a1db3b4845";
          sha256 = "sha256-QsnrGY/K8Qcoikqv+8aln1+V9xel6qfD/c/Nt1cTzHQ=";
          fetchSubmodules = true;
        };
      })).override
        {
          zig = pkgs.zigf.master;
        })
      rnix-lsp
      rust-analyzer
      nodePackages.pyright
      black
      sumneko-lua-language-server
      jdt-language-server
      nodePackages.bash-language-server
      clang-tools
      deno

      # need node 16 for copilot
      nodejs-16_x
    ];

    plugins = with pkgs.vimPlugins; [
      # ricing
      (pluginGit "nekonako/xresources-nvim" "745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582" "master")
      lualine-nvim
      bufferline-nvim
      bufdelete-nvim
      nvim-base16

      # libraries
      plenary-nvim
      sqlite-lua
      # lsp
      nvim-lspconfig
      null-ls-nvim
      lspkind-nvim
      trouble-nvim
      nvim-lightbulb
      lspsaga-nvim
      nvim-code-action-menu
      # treesitter
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
      nvim-treesitter-context
      nvim-ts-autotag
      # telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-frecency-nvim
      (pluginGit "nvim-telescope/telescope-ui-select.nvim" "d02a3d3a6b3f6b933c43a28668ae18f78846d3aa" "master")
      # nvim-autopairs
      nvim-autopairs
      # vim-vsnip
      vim-vsnip
      friendly-snippets
      # nvim-cmp
      nvim-cmp
      cmp-nvim-lsp
      cmp-vsnip
      cmp-treesitter
      cmp-path
      cmp-buffer
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
      zig-vim
      (pluginGit "lluchs/vim-wren" "713705a23bdb94ff6c29866ff4a9db089cbc2dab" "master")
      (pluginGit "stefanos82/nelua.vim" "60e67296bce29db0c060a21c9ad5423005a8f6eb" "main")
      (pluginGit "DingDean/wgsl.vim" "fbe8f0dd179aec8525d6c93bb992e409b0e4e0ee" "main")
      (pluginGit "elkowar/yuck.vim" "6dc3da77c53820c32648cf67cbdbdfb6994f4e08" "master")

      # lsp language additionals
      crates-nvim
      rust-tools-nvim

      # copilot
      # (pluginGit "zbirenbaum/copilot.lua" "5fbe531eb53f6a782d0fed7166f8cec23d606e84" "master")
      # (pluginGit "zbirenbaum/copilot-cmp" "4a8909fd63dff71001b22a287daa3830e447de70" "master")
      (pluginGit "github/copilot.vim" "1bfbaf5b027ee4d3d3dbc828c8bfaef2c45d132d" "release")
      cmp-copilot

      # firenvim
      (pluginGit "glacambre/firenvim" "56a49d79904921a8b4405786e12b4e12fbbf171b" "master")
    ];
  };
}
