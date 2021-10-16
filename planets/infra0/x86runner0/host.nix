{ pkgs, ... }: {
  networking.hostName = "x86runner0";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
  ];

  # important config
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.userDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp3s6.useDHCP = true;

  # --- open ports ---
  networking.firewall.allowedUDPPorts = [];
  networking.firewall.allowedTCPPorts = [];

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- wireguard vpn setup ---
  

  # --- wozey.service ---
  systemd.services."wozey" = {
    description = "wozey.service daemon";

    serviceConfig = {
      ExecStart = "${pkgs.wozey.wozey}/bin/wozey";
      WorkingDirectory = "/var/lib/wozey";
      Restart = "always";
      RestartSec = "5s";
    };

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  system.stateVersion = "21.11";
}
