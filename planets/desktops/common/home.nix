{ config, pkgs, lib, ... }:
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
    ./components/musicprod
    ./components/mcsr
  ];

  # packages
  home.packages = with pkgs; [
    # cli/tui untilities
    appimage-run
    beets
    chromaprint
    cryptsetup
    spotdl
    topydo
    ffmpeg
    exiftool
    gemini-cli
    opencode
    nur.repos.charmbracelet.crush
    master.claude-code
    imv
    inotify-tools
    iotop
    mpc
    fastfetch
    nom.default
    p7zip
    papis
    (python3.withPackages (
      ps: with ps; [
        distro
        numpy
        packaging
        pyudev
        requests
        systemd-python
        tqdm
        bitarray
        evdev
        mfusepy
        sounddevice
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
    ss.davinci-resolve-studio
    easyeffects
    file-roller
    freecad
    ghidra-bin
    gimp
    gnome-disk-utility
    horizon-eda
    jamesdsp
    keepassxc
    kicad
    krita
    libreoffice-fresh
    master.darktable
    openscad-unstable
    pear-desktop
    pkgsRocm.blender
    prismlauncher
    prusa-slicer
    rnote
    roomeqwizard
    signal-desktop
    sioyek
    solvespace
    thunderbird-latest
    transmission_4-gtk
    zathura

    # gaming stuff
    bottles
    (lutris.override { extraLibraries = pkgs: with pkgs; [ openssl ]; })
    gamescope
    gamescope-wsi
    protontricks
    nix-gaming.osu-lazer-bin
    unnamed-sdvx-clone
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
      configPath = "${config.xdg.configHome}/mozilla/firefox-devedition";
    };

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "10m";
      };
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
        droidcam-obs
        input-overlay
        # looking-glass-obs # TODO: broken
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

    nixcord = {
      enable = true;
      discord.enable = false;
      vesktop = {
        enable = true;
        settings = {
          discordBranch = "canary";
          minimizeToTray = false;
          arRPC = false;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
          disableMinSize = true;
        };
      };

      config = {
        themeLinks = [
          "https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/deploy/HorizontalServerList.theme.css"
        ];
        enabledThemes = [
          "https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/deploy/HorizontalServerList.theme.css"
        ];

        frameless = true;

        plugins = {
          betterGifAltText.enable = true;
          memberCount.enable = true;
          messageLogger = {
            enable = true;
            ignoreSelf = true;
            ignoreSelfEdits = true;
            separatedDiffs = true;
            showEditDiffs = true;
          };
          platformIndicators.enable = true;
          reverseImageSearch.enable = true;
          unindent.enable = true;
          voiceChatDoubleClick.enable = true;
          clearUrls.enable = true;
          whoReacted.enable = true;
          viewIcons.enable = true;
          typingIndicator.enable = true;
          typingTweaks.enable = true;
          viewRaw.enable = true;
          gifPaste.enable = true;
          implicitRelationships.enable = true;
          relationshipNotifier.enable = true;
          showAllMessageButtons.enable = true;
          permissionsViewer.enable = true;
          favoriteGifSearch.enable = true;
          showConnections.enable = true;
          copyUserUrls.enable = true;
          webKeybinds.enable = true;
          webScreenShareFixes.enable = true;
          copyFileContents.enable = true;
          alwaysExpandRoles.enable = true;
          volumeBooster = {
            enable = true;
            multiplier = 4.0;
          };
          disableDeepLinks.enable = true;
          imageFilename.enable = true;
        };
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

  # ensure ssh socket directory exists
  home.file.".ssh/sockets/.keep".text = "";
  # home-manager wrongly thinks it doesn't manage (and thus shouldn't clobber) this file due to the activation script
  home.file.".ssh/config".force = true;

  home.activation = {
    # https://github.com/nix-community/home-manager/issues/322
    fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -d -m 0700 "$HOME/.ssh"
      if [ -L "$HOME/.ssh/config" ]; then
        src="$(readlink -f "$HOME/.ssh/config")"
        run rm -f "$HOME/.ssh/config"
        run install -m 0600 "$src" "$HOME/.ssh/config"
      fi
    '';
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
