{pkgs, ...}: {
  networking.hostName = "wangshu";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
    ../common/profiles/vpn.nix
  ];

  # important config
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    useDHCP = false;
    interfaces = {
      enp2s0 = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
      enp3s6 = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };
  };

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
    ];
    allowedTCPPorts = [
    ];
    interfaces.orion = {
      allowedUDPPorts = [
      ];
      allowedTCPPorts = [
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [];

  system.stateVersion = "21.11";
}
