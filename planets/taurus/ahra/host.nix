{ config, pkgs, ... }:
{
  networking.hostName = "ahra";

  imports = [
    ../common/profiles/rpi5.nix
    ../common/profiles/vpn.nix
    ../common/components/common-metrics.nix
    ../common/containered-services/transmission.nix
  ];

  # --- mount disks ---
  fileSystems = { };

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [ ];
    allowedTCPPorts = [ ];
    interfaces.orion = {
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- metrics ---
  components.common-metrics.enable = true;

  system.stateVersion = "24.05";
}
