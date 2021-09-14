{ config, pkgs, lib, ... }:
let
  pluginGit = repo: rev: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}-${rev}";
    version = rev;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };
in
{
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    extraConfig = builtins.concatStringsSep "\n" [
      # (lib.strings.fileContents ./theme.vim)
      ''
        colorscheme xresources
      ''

      ''
        lua << EOF
        ${lib.strings.fileContents ./init.lua}
        EOF
      ''
    ];

    extraPackages = with pkgs; [
      tree-sitter
      gcc
      nodePackages.pyright
      nodePackages.dockerfile-language-server-nodejs
      rust-analyzer
      dart
      mpkgs.zls
      rnix-lsp
    ];

    plugins = with pkgs.vimPlugins; [
      (pluginGit "neovim/nvim-lspconfig" "251aa38a3ad87389e4e9dfb4ee745c312c25d740")
      (pluginGit "hrsh7th/nvim-compe" "5001cd7632b50b65f04d59af85a9dd199ea73b3a")
      (pluginGit "nvim-treesitter/nvim-treesitter" "a1b0e9ebb56f1042bc51e94252902ef14f688aaf")
      (pluginGit "nekonako/xresources-nvim" "e989bc88b5572b4be29efee42eb5c9c4e3e7edd1")

      which-key-nvim

      zig-vim
      vim-nix
      vim-flutter
      dart-vim-plugin
    ];
  };
}
