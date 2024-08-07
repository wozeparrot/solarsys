{ pkgs, ... }:
{
  networking.hostName = "veles";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
    ../common/profiles/vpn.nix
    ../common/components/common-metrics.nix
  ];

  # important config
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking = {
    useDHCP = false;
    interfaces.eno1 = {
      useDHCP = true;
      wakeOnLan.enable = true;
    };
  };

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [ ];
    allowedTCPPorts = [ ];
    interfaces.wg0 = {
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- metrics ---
  components.common-metrics.enable = true;

  system.stateVersion = "23.05";
}
