{ config, pkgs, lib, ... }:
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

  xdg.portal = {
    enable = true;
    #gtkUsePortal = true;
    extraPortals = with pkgs; [
      #xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  # audio
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ nerdfonts jetbrains-mono ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "JetBrains Mono:style=Regular" ];
    };
  };

  # environment
  environment = {
    systemPackages = with pkgs; [
      pavucontrol
      paprefs
      helvum
      pamixer
    ];
  };
}
