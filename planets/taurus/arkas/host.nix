{ config, pkgs, ... }:
{
  networking.hostName = "arkas";

  imports = [
    ../common/profiles/rpi3.nix
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

  # --- transmission ---
  containered-services.transmission.enable = true;

  system.stateVersion = "23.05";
}
