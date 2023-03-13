{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [./base.nix ./network.nix "${inputs.nix-gaming}/modules/pipewireLowLatency.nix"];

  # hardware
  hardware = {
    # opengl
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
      ];
    };
  };

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [dconf];

  xdg.portal = {
    enable = true;
    wlr = {
      settings = {
        screencast = {
          choose_type = "simple";
          chooser_cmd = "${pkgs.wofi}/bin/wofi -d -n --prompt='Select Monitor To Share: '";
        };
      };
    };
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
      quantum = 48;
      rate = 48000;
    };
  };

  # main theming
  stylix = {
    image = ../misc/wallpaper.png;
    polarity = "dark";
    base16Scheme = {
      base00 = "000000";
      base01 = "08040b";
      base02 = "554856";
      base03 = "705f72";
      base04 = "a293a5";
      base05 = "d2cad3";
      base06 = "f8f0f8";
      base07 = "494553";
      base08 = "a52e4d";
      base09 = "006fc1";
      base0A = "fa83a2";
      base0B = "228039";
      base0C = "33b3f4";
      base0D = "996f06";
      base0E = "aa3c9f";
      base0F = "554d5b";
    };
    fonts = rec {
      serif = sansSerif;

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
    };
  };
  fonts.enableDefaultFonts = true;
  # fonts = {
  #   enableDefaultFonts = true;
  #   fonts = with pkgs; [
  #     nerdfonts
  #     agave
  #     vegur
  #     tenderness
  #     source-han-mono
  #     source-han-sans
  #     source-han-serif
  #
  #     # fallback
  #     noto-fonts
  #     noto-fonts-extra
  #     noto-fonts-emoji
  #     noto-fonts-cjk-sans
  #     noto-fonts-cjk-serif
  #
  #     # super fallback
  #     last-resort
  #   ];
  #
  #   fontconfig = {
  #     defaultFonts = {
  #       monospace = [
  #         "Agave Nerd Font"
  #         "Source Han Mono"
  #         "Noto Sans Mono CJK JP"
  #         "Noto Emoji"
  #         "Noto Sans"
  #         "Last Resort"
  #       ];
  #       sansSerif = [
  #         "Vegur"
  #         "Source Han Sans"
  #         "Noto Sans CJK JP"
  #         "Noto Emoji"
  #         "Noto Sans"
  #         "Last Resort"
  #       ];
  #       serif = [
  #         "Tenderness"
  #         "Source Han Serif"
  #         "Noto Serif CJK JP"
  #         "Noto Emoji"
  #         "Noto Serif"
  #         "Last Resort"
  #       ];
  #     };
  #   };
  # };

  services.udev.packages = [pkgs.gnome.gnome-settings-daemon];

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
      gnome.adwaita-icon-theme
      papirus-icon-theme

      libnotify
      xdg-utils

      gsettings-desktop-schemas
      glib
    ];
    sessionVariables.XDG_DATA_DIRS = let
      missing-gsettings-schemas-fix = builtins.readFile "${pkgs.stdenv.mkDerivation {
        name = "missing-gsettings-schemas-fix";
        dontUnpack = true;
        buildInputs = [pkgs.gtk3];
        installPhase = ''
          printf %s "$GSETTINGS_SCHEMAS_PATH" > "$out"
        '';
      }}";
    in
      lib.mkAfter ["${missing-gsettings-schemas-fix}"];
  };
}
