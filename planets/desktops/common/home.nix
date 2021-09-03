{ pkgs, ... }:

{
  imports = [
    ./components/neovim
    ./components/helix
    ./components/intershell
    ./components/git
    ./components/mpdplus
    ./components/keepassxc
    ./components/kitty
    ./components/mpv
    ./components/shfm
  ];

  # packages
  home.packages = with pkgs; [
    vscode

    gdb
    rustup
    nixpkgs-fmt
    python3
    ruby

    blender
    godot
    gimp
    lmms
    libsForQt5.kdenlive
    transmission-gtk
    libreoffice-fresh
    ghidra-bin
    solvespace
    antimony
    openscad
    freecad
    krita
    kicad-unstable
    zettlr
    audacity
    antimicroX
    youtube-dl
    r128gain
    ffmpeg
    vlc

    gitAndTools.hub

    multimc
    mpkgs.steam
    mpkgs.steam.run
    mpkgs.protontricks
    mpkgs.lutris
    the-powder-toy
    mpkgs.osu-lazer

    ranger
    feh

    grim
    slurp
    wf-recorder
    wl-clipboard
    xclip
    xsel

    mpc_cli
    neofetch
    bottom
    iotop

    keepassxc
    etcher

    unzip
    p7zip

    ss.discord-canary

    qt5.qtwayland
    adwaita-qt

    xorg.xrdb
  ];

  # extra programs
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.keychain.enable = false; # currently broken, prevents window manager from starting on boot

  # extra services
  services.kdeconnect.enable = true;
  services.easyeffects.enable = false; # causes some problems

  # xdg config
  xdg.enable = true;

  # theming
  gtk = {
    theme = {
      package = pkgs.gnome3.gnome_themes_standard;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      name = "Agave Nerd Font";
      size = 11;
    };
    enable = true;
  };

  qt = {
    enable = true;
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };

  xresources.properties = {
    background = "#000000";
    foreground = "#d2cad3";
    color0 = "#08040b";
    color8 = "#554d5b";
    color1 = "#a52e4d";
    color9 = "#fa83a2";
    color2 = "#228039";
    color10 = "#44a29f";
    color3 = "#996f06";
    color11 = "#ddc47d";
    color4 = "#006fc1";
    color12 = "#6691d2";
    color5 = "#aa3c9f";
    color13 = "#c29dd5";
    color6 = "#33b3f4";
    color14 = "#88c4f4";
    color7 = "#bbb3c1";
    color15 = "#f8f0f8";
  };

  # home manager stuff
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    VISUAL = "nvim";
    EDITOR = "nvim";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  home.username = "woze";
  home.homeDirectory = "/home/woze";

  programs.home-manager.enable = true;
  home.stateVersion = "20.09";
}
