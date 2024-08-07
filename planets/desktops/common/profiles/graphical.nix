{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./base.nix
    ./network.nix
    "${inputs.nix-gaming}/modules/pipewireLowLatency.nix"
  ];

  # hardware
  hardware = {
    # acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
  };

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  # audio
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;

    lowLatency = {
      enable = true;
      quantum = 64;
      rate = 48000;
    };

    wireplumber.extraConfig = {
      "10-disable-camera" = {
        "wireplumber.profiles" = {
          "main" = {
            "monitor.libcamera" = "disabled";
          };
        };
      };
    };
  };

  # main theming
  stylix = {
    enable = true;
    image = ../misc/wallpaper.png;
    polarity = "dark";
    base16Scheme = {
      base00 = "000000"; # ---- dark
      base01 = "111111"; # ---
      base02 = "554856"; # --
      base03 = "705f72"; # -
      base04 = "9f95a1"; # +
      base05 = "bbb3c1"; # ++
      base06 = "d2cad3"; # +++
      base07 = "f8f0f8"; # ++++ light
      base08 = "a52e4d"; # red
      base09 = "c4543d"; # orange
      base0A = "a78f2f"; # yellow
      base0B = "228039"; # green
      base0C = "1ba8e8"; # cyan
      base0D = "006fc1"; # blue
      base0E = "8656a7"; # purple
      base0F = "e77ca0"; # pink
    };
    fonts = {
      serif = config.stylix.fonts.sansSerif;

      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };

      monospace = {
        package = pkgs.nerdfonts;
        name = "Agave Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 11;
        terminal = 12;
      };
    };
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 24;
    };
  };
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerdfonts

      # fallback
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # super fallback
      last-resort
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [
          "Agave Nerd Font"
          "Noto Sans Mono"
          "Noto Sans Mono CJK JP"
          "Noto Emoji"
          "Last Resort"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK JP"
          "Noto Emoji"
          "Last Resort"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK JP"
          "Noto Emoji"
          "Last Resort"
        ];
      };
    };
  };

  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

  # environment
  environment = {
    systemPackages = with pkgs; [
      pulseaudio
      pavucontrol
      paprefs
      helvum
      pamixer

      gtk-engine-murrine
      hicolor-icon-theme
      adwaita-icon-theme
      papirus-icon-theme
      nwg-look

      libnotify
      xdg-utils

      gsettings-desktop-schemas
      glib
    ];
    sessionVariables.XDG_DATA_DIRS =
      let
        missing-gsettings-schemas-fix = builtins.readFile "${pkgs.stdenv.mkDerivation {
          name = "missing-gsettings-schemas-fix";
          dontUnpack = true;
          buildInputs = [ pkgs.gtk3 ];
          installPhase = ''
            printf %s "$GSETTINGS_SCHEMAS_PATH" > "$out"
          '';
        }}";
      in
      lib.mkAfter [ "${missing-gsettings-schemas-fix}" ];
  };
}
