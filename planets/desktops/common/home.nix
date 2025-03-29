{ pkgs, lib, ... }:
{
  imports = [
    ./components/neovim
    # ./components/helix
    ./components/intershell
    ./components/git
    ./components/mpdplus
    ./components/keepassxc
    ./components/kitty
    ./components/mpv
    # ./components/shfm
    # ./components/musicprod
  ];

  # packages
  home.packages = with pkgs; [
    # cli/tui untilities
    appimage-run
    beets-unstable
    chromaprint
    spotdl
    topydo
    ffmpeg
    # gurk-rs
    imv
    inotify-tools
    iotop
    mpc_cli
    neofetch
    nom.default
    p7zip
    (python3.withPackages (
      ps: with ps; [
        distro
        numpy
        packaging
        pyudev
        requests
        systemd
        tqdm
        bitarray
      ]
    ))
    r128gain
    ranger
    restic
    ruby
    ss.mods
    swayimg
    unzip
    yt-dlp

    # applications
    antimicrox
    antimony
    audacity
    blender-hip
    darktable
    # freecad
    ghidra-bin
    gimp
    file-roller
    gnome-disk-utility
    # jamesdsp
    keepassxc
    # kicad
    krita
    libreoffice-fresh
    libsForQt5.kdenlive
    # nheko
    openscad
    prismlauncher
    rnote
    signal-desktop
    sioyek
    solvespace
    ss.horizon
    thunderbird-latest
    transmission_4-gtk
    vesktop
    zathura

    # gaming stuff
    master.bottles
    (lutris.override { extraLibraries = pkgs: with pkgs; [ openssl ]; })
    chaotic.gamescope_git
    chaotic.gamescope-wsi_git
    master.protontricks
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
      keys = [ "id_ed25519" ];
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
        # droidcam-obs # TODO: broken
        input-overlay
        looking-glass-obs
        obs-gstreamer
        obs-move-transition
        obs-shaderfilter
        obs-tuna
        # obs-vertical-canvas # TODO: broken
        obs-vkcapture
        waveform
        wlrobs
      ];
    };

    btop = {
      enable = true;
      settings = {
        update_ms = 100;
        mem_graphs = false;
        swap_disk = false;
      };
    };
  };

  # extra services
  services = {
    kdeconnect.enable = true;
    kdeconnect.indicator = true;
    syncthing.enable = true;
  };

  # fix for flake
  services.hyprpaper.package = lib.mkDefault pkgs.hyprpaper.hyprpaper;

  # xdg config
  xdg.enable = true;

  stylix.targets.xresources.enable = true;
  stylix.targets.waybar.enable = false;
  stylix.targets.xfce.enable = false;
  stylix.targets.kde.enable = false;
  stylix.targets.hyprlock.enable = false;
  stylix.targets.gnome-text-editor.enable = false;
  stylix.targets.firefox.enable = false;

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
