{ pkgs, lib, ... }:

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
    #./components/musicprod
  ];

  # packages
  home.packages = with pkgs; [
    #vscode

    gdb
    rustc
    cargo
    nixpkgs-fmt
    python3
    ruby
    zig

    blender
    godot
    gimp
    libsForQt5.kdenlive
    transmission-gtk
    libreoffice
    ghidra-bin
    solvespace
    antimony
    openscad
    # freecad
    krita
    kicad
    ss.horizon
    audacity
    antimicroX
    yt-dlp
    r128gain
    ffmpeg
    zathura

    master.polymc
    master.protontricks
    (lutris.override {
      extraLibraries = pkgs: with pkgs; [
        openssl
      ];
    })
    master.steam # not using the normal way as we need steam from master
    master.steam.run # ^ required settings from programs.steam.enable should be set in each hosts config
    master.steamcmd # ^
    master.steam-tui # ^
    the-powder-toy
    nix-gaming.osu-lazer-bin
    bottles
    appimage-run

    ranger
    imv

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

    unzip
    p7zip

    ss.goosemod.discord-canary
    # nheko # TODO: uncomment when #176246 lands

    gtk-engine-murrine
    qt5.qtwayland
    xorg.xrdb


    pkgs.aninarr.aninarc
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
    keys = [ "id_ed25519" ];
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
      wlrobs
      obs-websocket
      obs-move-transition
      obs-gstreamer
    ];
  };

  programs.vscode = {
    enable = false;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      redhat.java
      tiehuis.zig
      bbenoist.nix
      jnoortheen.nix-ide
      eamodio.gitlens
      antyos.openscad
      mikestead.dotenv
      vadimcn.vscode-lldb
      timonwong.shellcheck
      matklad.rust-analyzer
      tamasfe.even-better-toml
      asvetliakov.vscode-neovim
      arrterian.nix-env-selector
      streetsidesoftware.code-spell-checker
      mads-hartmann.bash-ide-vscode
      asciidoctor.asciidoctor-vscode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
  services.easyeffects.enable = false; # causes some problems
  services.syncthing.enable = true;

  # xdg config
  xdg.enable = true;

  # theming
  gtk = {
    theme = {
      package = pkgs.orchis-theme.override {
        tweaks = [ "compact" "black" "primary" ];
      };
      name = "Orchis-Purple-Dark-Compact";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    font = {
      name = "Vegur";
      size = 11;
    };
    enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
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

  home.stateVersion = lib.mkDefault "22.05";
}
