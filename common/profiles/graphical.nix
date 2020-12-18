{ config, pkgs, mpkgs, lib, ... }:
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

    # pulseaudio
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
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
      disableWhileTyping = false;
    };
  };

  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
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

      keepassxc

      pavucontrol
      paprefs
    ];
  };
}
