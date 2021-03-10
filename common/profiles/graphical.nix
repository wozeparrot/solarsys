{ stdenv, config, pkgs, mpkgs, ... }:
{
  imports = [ ./base.nix ./network.nix ];

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

  # xserver
  services.xserver = {
    enable = true;

    layout = "us";

    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = false;
        naturalScrolling = true;
      };
      mouse = {
        middleEmulation = false;
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # audio
  hardware.pulseaudio.enable = stdenv.lib.mkForce false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # fonts
  fonts = {
    fonts = with pkgs; [ nerdfonts jetbrains-mono ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "JetBrains Mono:style=Regular" ];
    };
  };

  # environment (mostly for root themes)
  environment = {
    etc = {
      "xdg/gtk-3.0/settings.ini" = {
        text = ''
          [Settings]
          gtk-icon-theme-name=Paper-Mono_Dark
          gtk-cursor-theme-name=Paper
          gtk-theme-name=Dracula
        '';
        mode = "444";
      };
    };
    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "gtk2";
      GTK2_RC_FILES =
        let
          gtk = ''
            gtk-icon-theme-name="Paper-Mono-Dark"
            gtk-cursor-theme-name="Paper"
          '';
        in
        [
          ("${pkgs.writeText "iconrc" "${gtk}"}")
          "${pkgs.dracula-theme}/share/themes/Dracula/gtk-2.0/gtkrc"
        ];
    };
    systemPackages = with pkgs; [
      dracula-theme
      paper-icon-theme
      libsForQt5.qtstyleplugins

      pavucontrol
      paprefs
      qjackctl
      patchage
      pamixer
    ];
  };
}
