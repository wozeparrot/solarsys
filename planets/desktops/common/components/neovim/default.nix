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
      clang-tools
      deno
    ];

    plugins = with pkgs.vimPlugins; [
      # ricing
      (pluginGit "nekonako/xresources-nvim" "745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582" "master")
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

      # lsp language additionals
      crates-nvim
      rust-tools-nvim
    ];
  };
}
