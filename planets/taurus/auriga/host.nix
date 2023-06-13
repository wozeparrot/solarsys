{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "auriga";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/seaweedfs-node.nix
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

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  # --- seaweedfs ---
  containered-services.seaweedfs-node = {
    enable = true;
    bindAddress = "10.11.235.22";
    volumes = [
      "/mnt/pstore0/seaweedfs/volume"
    ];
  };

  system.stateVersion = "23.05";
}
