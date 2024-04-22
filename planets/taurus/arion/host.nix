{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "arion";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/nextcloud.nix
    ../common/containered-services/motioneye.nix
    ../common/components/common-metrics.nix
  ];

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

  # --- metrics ---
  components.common-metrics.enable = true;

  # --- nextcloud ---
  containered-services.nextcloud.enable = true;

  # --- motioneye ---
  containered-services.motioneye.enable = true;

  system.stateVersion = "23.05";
}
