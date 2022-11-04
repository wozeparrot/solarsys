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
    topydo
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
    libreoffice-fresh # switch back to normal once #199314 lands
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
    bottles
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
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  programs.keychain = {
    enable = true;
    enableXsessionIntegration = false;
    keys = ["id_ed25519"];
  };

  programs.mangohud = {
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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-gstreamer
      obs-move-transition
      obs-websocket
      wlrobs
    ];
  };

  programs.vscode = {
    enable = false;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions;
      [
        antyos.openscad
        arrterian.nix-env-selector
        asciidoctor.asciidoctor-vscode
        asvetliakov.vscode-neovim
        bbenoist.nix
        eamodio.gitlens
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        matklad.rust-analyzer
        mikestead.dotenv
        redhat.java
        streetsidesoftware.code-spell-checker
        tamasfe.even-better-toml
        tiehuis.zig
        timonwong.shellcheck
        vadimcn.vscode-lldb
        yzhang.markdown-all-in-one
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "xresources-theme";
          publisher = "JackVandergriff";
          version = "1.1.0";
          sha256 = "sha256-pzs9Y6bYxG8cEjBxU2VPW9rq/VPWo/gl7JilheNJ6v8=";
        }
        {
          name = "vscode-direnv";
          publisher = "cab404";
          version = "1.0.0";
          sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
        }
      ];
  };

  # extra services
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;
  # services.easyeffects.enable = true; # not working atm
  services.syncthing.enable = true;

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

  home.stateVersion = lib.mkDefault "22.05";
}
