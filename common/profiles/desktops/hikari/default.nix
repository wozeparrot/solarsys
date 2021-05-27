{ config, pkgs, ... }:
{
  # home-manager config
  home-manager.users.woze = {
    xdg.configFile."hikari/hikari.conf".source = ./hikari.conf;

    home.packages = with pkgs; [
      wofi
    ];

    programs.mako = {
      enable = true;
    };

    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 20;
          output = [
            "eDP-1"
          ];
          modules-left = [ "battery" "network" "cpu" "memory" ];
          modules-center = [ "mpd" ];
          modules-right = [ "backlight" "pulseaudio" "clock" "tray" ];
        }
      ];
    };
  };

  # system config
  environment.systemPackages = with pkgs; [
    hikari
  ];

  programs.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd hikari";
      };
    };
  };

  security.pam.services.hikari-unlocker = {};
}
