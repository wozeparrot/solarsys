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
in
{
  home.packages = with pkgs; [ neovide ];

  # programs.nixvim = {
  #   enable = true;
  # };

  programs.neovim = {
    enable = true;
    withNodeJs = true;

    extraLuaConfig = builtins.concatStringsSep "\n" [
      ""
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
      pyright
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
      telescope-ui-select-nvim
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
      (pluginGit "avivbeeri/vim-wren" "2514d32c8e476384f3df81bd2cd369908d85bcfe" "fixedStatic")
      (pluginGit "stefanos82/nelua.vim" "ff0a733a586ef0b48cda4999170ed4ca1653a144" "main")
      (pluginGit "NlGHT/vim-eel" "7c1357b098629cf952ff7b2b6900295093c1bbeb" "master")
      vim-opencl
      wgsl-vim
      yuck-vim
      zig-vim

      # lsp language additionals
      crates-nvim
      rust-tools-nvim

      # copilot
      (pluginGit "zbirenbaum/copilot.lua" "886ee73b6d464b2b3e3e6a7ff55ce87feac423a9" "master")
      (pluginGit "zbirenbaum/copilot-cmp" "15fc12af3d0109fa76b60b5cffa1373697e261d1" "master")

      # firenvim
      (pluginGit "glacambre/firenvim" "4d2eef5fd2a7af0e91b76f1a9715228548316125" "master")

      # virt-column
      (pluginGit "xiyaowong/virtcolumn.nvim" "4d385b4aa42aa3af6fa2cb8527462fa4badbd163" "main")
    ];
  };
}
