{ config, pkgs, lib, vimUtils, ... }:
let
  pluginGit = ref: repo: vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };

  pluginH = pluginGit "HEAD";
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./theme.vim)

      ''
        lua << EOF
        ${lib.strings.fileContents ./init.lua}
        EOF
      ''
    ];

    extraPackages = with pkgs; [
      tree-sitter

      nodePackages.pyright
      rust-analyzer
      zls
    ];

    plugins = with pkgs.vimPlugins; [
      (pluginH "neovim/nvim-lspconfig")
      (pluginH "nvim-lua/nvim-compe")
    ];
  };
}
