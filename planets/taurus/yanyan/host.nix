{ config, pkgs, ... }:
{
  networking.hostName = "yanyan";

  imports = [
    ../common/profiles/rk3588.nix
    # ../common/profiles/vpn.nix
    ../common/containered-services/nats.nix
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

  system.stateVersion = "25.11";
}
