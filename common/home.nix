{ pkgs, mpkgs, ... }:

{
  imports = [
    ./components/neovim
    ./components/intershell
    ./components/git
    ./components/mpdplus
    ./components/keepassxc
    ./components/kitty
    ./components/mpv
  ];

  # packages
  home.packages = with pkgs; [
    vscode

    gdb
    rustup
    nixpkgs-fmt
    python3

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
    vorbisgain
    ffmpeg
    vlc

    gitAndTools.hub

    multimc
    steam-run
    protontricks
    lutris
    steam
    the-powder-toy
    mpkgs.osu-lazer

    xdo
    xdotool
    shotgun
    arandr
    xclip
    slop
    flameshot
    cli-visualizer

    ranger
    feh

    mpc_cli
    neofetch
    onefetch
    bottom
    iotop

    keepassxc
    etcher

    unzip
    p7zip

    mpkgs.discord
  ];

  # extra programs
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.keychain.enable = false; # currently broken, prevents window manager from starting on boot

  # extra services
  services.kdeconnect.enable = true;
  services.pulseeffects = {
    enable = false; # still broken
    package = pkgs.pulseeffects-pw;
  };

  # x config
  xdg.enable = true;

  # theming
  gtk = {
    theme = {
      package = pkgs.shades-of-gray-theme;
      name = "Shades-of-gray-Patina";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
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
