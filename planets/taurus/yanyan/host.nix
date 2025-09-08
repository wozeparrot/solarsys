{ config, pkgs, ... }:
{
  networking.hostName = "yanyan";

  imports = [
    ../common/profiles/rk3588.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/nats.nix
    ../common/containered-services/blocky.nix
  ];

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

  # --- services
  containered-services.nats.enable = true;
  containered-services.blocky.enable = true;

  system.stateVersion = "25.11";
}
