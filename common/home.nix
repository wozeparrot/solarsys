{ pkgs, ... }:

{
  imports = [
    ./components/neovim
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
    pkgs.mpkgs.osu-lazer

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

    pkgs.mpkgs.discord-canary

    qt5.qtwayland
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

  # xdg config
  xdg.enable = true;

  # theming
  gtk = {
    theme = {
      package = pkgs.gnome3.gnome_themes_standard;
      name = "Adwaita";
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
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
