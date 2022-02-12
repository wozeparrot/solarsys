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
      ''
        if exists('g:vscode')
          colorscheme default
        else
          colorscheme xresources
        endif
      ''

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
      zls
      rnix-lsp
      rust-analyzer
      nodePackages.pyright
      black
      sumneko-lua-language-server
      java-language-server
      nodePackages.vscode-json-languageserver
      nodePackages.bash-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      # ricing
      (pluginGit "nekonako/xresources-nvim" "745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582")
      lualine-nvim
      bufferline-nvim
      bufdelete-nvim

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
      nvim-treesitter
      nvim-treesitter-context
      nvim-ts-autotag
      # telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-frecency-nvim
      (pluginGit "nvim-telescope/telescope-ui-select.nvim" "d02a3d3a6b3f6b933c43a28668ae18f78846d3aa")
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

      # lsp language additionals
      crates-nvim
      rust-tools-nvim
    ];
  };
}
