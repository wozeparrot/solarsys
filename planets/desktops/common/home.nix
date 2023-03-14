{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./components/neovim
    # ./components/helix
    ./components/intershell
    ./components/git
    ./components/mpdplus
    ./components/keepassxc
    ./components/kitty
    ./components/mpv
    ./components/shfm
    ./components/musicprod
  ];

  # packages
  home.packages = with pkgs; [
    # cli/tui untilities
    appimage-run
    beets-unstable
    chromaprint
    ffmpeg
    gurk-rs
    imv
    iotop
    mpc_cli
    neofetch
    nom.default
    p7zip
    python3
    r128gain
    ranger
    ruby
    spotdl
    # topydo # TODO: broken
    unzip
    yt-dlp

    # applications
    antimicroX
    antimony
    audacity
    blender
    ghidra-bin
    gimp
    gnome.file-roller
    gnome.gnome-disk-utility
    godot
    jamesdsp
    keepassxc
    krita
    libreoffice-fresh
    libsForQt5.kdenlive
    sioyek
    nheko
    openscad
    pkgs.aninarr.aninarc
    prismlauncher
    signal-desktop
    solvespace
    ss.horizon
    thunderbird
    transmission-gtk
    webcord.webcord
    zathura

    # gaming stuff
    master.bottles
    (lutris.override {
      extraLibraries = pkgs:
        with pkgs; [
          openssl
        ];
    })
    gamescope
    master.protontricks
    master.steam-tui
    master.steamcmd
    nix-gaming.osu-lazer-bin
    the-powder-toy
    wine64

    # wayland/desktop stuff
    grim
    slurp
    wf-recorder
    wl-clipboard
    xclip
    xsel

    # theme stuff
    gtk-engine-murrine
    qt5.qtwayland
    xorg.xrdb
  ];

  # extra programs
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
    };

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    keychain = {
      enable = true;
      enableXsessionIntegration = false;
      keys = ["id_ed25519"];
    };

    mangohud = {
      enable = true;
      settings = {
        full = true;
      };
      settingsPerApplication = {
        mpv = {
          no_display = true;
        };
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-gstreamer
        obs-move-transition
        wlrobs
      ];
    };
  };

  # extra services
  services = {
    kdeconnect.enable = true;
    kdeconnect.indicator = true;
    syncthing.enable = true;
  };

  # xdg config
  xdg.enable = true;

  # theming
  qt = {
    enable = true;
    platformTheme = "gtk";
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

  # home stuff
  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      VISUAL = "nvim";
      EDITOR = "nvim";
      SHELL = "${pkgs.fish}/bin/fish";
    };

    username = "woze";
    homeDirectory = "/home/woze";
  };

  programs.home-manager.enable = true;

  home.stateVersion = lib.mkDefault "22.05";
}
