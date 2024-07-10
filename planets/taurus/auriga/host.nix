{ config, pkgs, ... }:
{
  networking.hostName = "auriga";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/seaweedfs-node.nix
    ../common/containered-services/blocky.nix
    ../common/components/common-metrics.nix
    ../common/components/speedtest-metric.nix
  ];

  # --- mount disks ---
  fileSystems = {
    "/mnt/pstore0" = {
      device = "/dev/disk/by-uuid/b26f275b-b03d-4895-89e2-c986cab78a00";
      fsType = "xfs";
    };
  };

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
    interfaces.orion = {
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- metrics ---
  components.common-metrics.enable = true;
  components.speedtest-metric.enable = true;

  # --- seaweedfs ---
  containered-services.seaweedfs-node = {
    enable = true;
    bindAddress = "10.11.235.22";
    volumes = [ "/mnt/pstore0/seaweedfs/volume" ];
  };

  # --- blocky ---
  containered-services.blocky.enable = true;

  system.stateVersion = "23.05";
}
