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
    # spotdl # TODO: broken
    # topydo # TODO: broken
    ffmpeg
    gurk-rs
    imv
    iotop
    mpc_cli
    neofetch
    nom.default
    p7zip
    (python3.withPackages (
      ps:
        with ps; [
          requests
          tqdm
        ]
    ))
    r128gain
    ranger
    restic
    ruby
    ss.mods
    unzip
    yt-dlp

    # applications
    antimicroX
    antimony
    audacity
    blender-hip
    darktable
    freecad
    ghidra-bin
    gimp
    gnome.file-roller
    gnome.gnome-disk-utility
    jamesdsp
    keepassxc
    # kicad
    krita
    libreoffice-fresh
    libsForQt5.kdenlive
    nheko
    openscad
    prismlauncher
    rnote
    signal-desktop
    sioyek
    solvespace
    ss.horizon
    thunderbird
    transmission-gtk
    vesktop
    zathura

    # gaming stuff
    master.bottles
    (lutris.override {
      extraLibraries = pkgs:
        with pkgs; [
          openssl
        ];
    })
    chaotic.gamescope_git
    chaotic.gamescope-wsi_git
    master.protontricks
    nix-gaming.osu-lazer-bin
    # the-powder-toy
    wine64

    # wayland/desktop stuff
    grim
    slurp
    sunshine
    wf-recorder
    wl-clipboard
    xclip
    xsel

    # theme stuff
    gtk-engine-murrine
    qt5.qtwayland
  ];

  # extra programs
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
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
        droidcam-obs
        input-overlay
        looking-glass-obs
        obs-gstreamer
        obs-move-transition
        obs-shaderfilter
        obs-tuna
        obs-vertical-canvas
        obs-vkcapture
        waveform
        wlrobs
      ];
    };

    btop = {
      enable = true;
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
    platformTheme.name = "gtk3";
  };

  stylix.targets.xresources.enable = true;
  stylix.targets.waybar.enable = false;
  stylix.targets.xfce.enable = false;
  stylix.targets.kde.enable = false;

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
