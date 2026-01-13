{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "wlab";

  imports = [
    ./hardware.nix

    ../common/profiles/laptop.nix

    ../common/profiles/desktops/hyprland
  ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  services.xserver.videoDrivers = [
    "modesetting"
  ];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    # viture pro xr (35ca:101d)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="35ca", ATTRS{idProduct}=="101d", MODE="0666"
  '';
  services.udev.packages = with pkgs; [
  ];

  networking.firewall.allowedTCPPorts = [ 29999 ];
  networking.firewall.allowedUDPPorts = [ 29999 ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];

  # ssh
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = false;
      PasswordAuthentication = false;
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      terminal = {
        vt = 1;
      };
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "woze";
      };
      default_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "woze";
      };
    };
  };

  systemd.services.op3ht = {
    description = "op3ht service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/home/woze/projects/osmo_pocket_3_head_tracking";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s op3ht /home/woze/projects/osmo_pocket_3_head_tracking/launch.sh";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t op3ht";
      TimeoutStopSec = 1;
      User = "woze";
      Group = "users";
    };
  };

  programs.waybar.enable = false;

  environment.systemPackages = with pkgs; [
    waypipe
    iwgtk
  ];

  stylix.image = ../common/misc/black.png;

  home-manager.users.woze = ./home.nix;

  system.stateVersion = "25.11";
}
