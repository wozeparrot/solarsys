{ config, pkgs, mpkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      zig-vim
      vim-nix
      rust-vim

      coc-nvim
      coc-git
      coc-json
      coc-yaml
      coc-rust-analyzer

      vim-airline
      vim-airline-themes
    ];
    extraConfig = builtins.readFile ./init.vim;
  };
}
