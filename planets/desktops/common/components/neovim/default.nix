{
  config,
  pkgs,
  lib,
  ...
}: let
  pluginGit = repo: rev: ref:
    pkgs.vimUtils.buildVimPlugin {
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
    withNodeJs = true;

    extraLuaConfig = builtins.concatStringsSep "\n" [
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
      nodePackages.pyright
      rust-analyzer
      rustc
      rustfmt
      svls
      verible
      zls.zls

      # formatters
      alejandra
      stylua

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
      (pluginGit "lewis6991/impatient.nvim" "c90e273f7b8c50a02f956c24ce4804a47f18162e" "main")
      # lsp
      lspkind-nvim
      lspsaga-nvim
      null-ls-nvim
      nvim-code-action-menu
      nvim-lspconfig
      trouble-nvim
      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-ts-autotag
      # telescope
      (pluginGit "nvim-telescope/telescope-ui-select.nvim" "62ea5e58c7bbe191297b983a9e7e89420f581369" "master")
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
      (pluginGit "luckasRanarison/tree-sitter-hypr" "90b3ddf8a85b5ea3d9dc4920fddb16182a192e14" "master")
      zig-vim
      vim-opencl

      # lsp language additionals
      crates-nvim
      rust-tools-nvim

      # copilot
      copilot-vim
      cmp-copilot
      # (pluginGit "zbirenbaum/copilot.lua" "b41d4c9c7d4f5e0272bcf94061b88e244904c56f" "master")
      # (pluginGit "zbirenbaum/copilot-cmp" "92535dfd9c430b49ca7d9a7da336c5db65826b65" "master")

      # firenvim
      (pluginGit "glacambre/firenvim" "ee4ef314bd990b2b05b7fbd95b857159e444a2fe" "master")
    ];
  };
}
