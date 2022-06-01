{ config, pkgs, lib, inputs, ... }:
{
  imports = [ ./base.nix ./network.nix "${inputs.nix-gaming}/modules/pipewireLowLatency.nix" ];

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
  services.dbus.packages = with pkgs; [ dconf ];

  xdg.portal = {
    enable = true;
    gtkUsePortal = false; # something changed??? not really sure so TODO
    wlr = {
      enable = true;
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

  # fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      nerdfonts
      agave
      vegur
      tenderness
      source-han-mono
      source-han-sans
      source-han-serif

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
          "Source Han Mono"
          "Noto Sans Mono CJK JP"
          "Noto Emoji"
          "Noto Sans"
          "Last Resort"
        ];
        sansSerif = [
          "Vegur"
          "Source Han Sans"
          "Noto Sans CJK JP"
          "Noto Emoji"
          "Noto Sans"
          "Last Resort"
        ];
        serif = [
          "Tenderness"
          "Source Han Serif"
          "Noto Serif CJK JP"
          "Noto Emoji"
          "Noto Serif"
          "Last Resort"
        ];
      };
    };
  };

  services.udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

  # environment
  environment = {
    systemPackages = with pkgs; [
      pavucontrol
      paprefs
      helvum
      pamixer

      gtk-engine-murrine
      hicolor-icon-theme
      gnome3.adwaita-icon-theme
      papirus-icon-theme

      libnotify
      xdg-utils

      gsettings-desktop-schemas
      glib
    ];
  };
}
