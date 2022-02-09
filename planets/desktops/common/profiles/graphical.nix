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
    gtkUsePortal = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 30;
          choose_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or -s '#12345655' -b '#65432155'";
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
      noto-fonts-cjk
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [
          "Agave Nerd Font"
          "Noto Sans Japanese"
        ];
        sansSerif = [
          "Vegur"
          "Noto Sans Japanese"
        ];
        serif = [
          "Tenderness"
          "Noto Serif Japanese"
        ];
      };
    };
  };

  # environment
  environment = {
    systemPackages = with pkgs; [
      pavucontrol
      paprefs
      helvum
      pamixer

      hicolor-icon-theme
      tela-icon-theme

      libnotify
      xdg-utils
    ];
  };
}
