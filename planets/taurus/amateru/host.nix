{pkgs, ...}: {
  networking.hostName = "amateru";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/seaweedfs-master.nix
    ../common/containered-services/seaweedfs-node.nix
    ../common/containered-services/metrics.nix
  ];

  # --- mount disks ---
  fileSystems = {
    "/mnt/pstore0" = {
      device = "/dev/disk/by-uuid/bbdea403-5106-47d1-8742-f3f4449257b7";
      fsType = "btrfs";
    };
    "/mnt/pstore1" = {
      device = "/dev/disk/by-uuid/823e9830-4af1-42cc-929c-05fcf078326c";
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
        8384 # syncthing
        22000

        111 # nfs
        2049
        4000
        4001
        4002
        20048
      ];
      allowedTCPPorts = [
        8384 # syncthing
        22000

        111 # nfs
        2049
        4000
        4001
        4002
        20048

        5072 # export directory to a lighttpd server
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [];

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  # --- metrics ---
  containered-services.metrics.enable = true;
  systemd.services."container@metrics".after = ["container@seaweedfs-master"];

  # --- remote filesystem access ---
  fileSystems = {
    "/export/anime" = {
      device = "/mnt/pstore1/datas/aninarr/anime";
      options = ["bind"];
    };
    "/export/store" = {
      device = "/mnt/pstore1/datas/aninarr/store";
      options = ["bind"];
    };
    "/export/export" = {
      device = "/mnt/pstore1/datas/export";
      options = ["bind"];
    };
  };
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /export               *(insecure,ro,no_root_squash,async,no_subtree_check,crossmnt,fsid=0)
      /export/anime         *(insecure,ro,no_root_squash,async,no_subtree_check)
      /export/store         *(insecure,ro,no_root_squash,async,no_subtree_check)
      /export/export        *(insecure,ro,no_root_squash,async,no_subtree_check)
    '';
  };

  services.lighttpd = {
    enable = true;
    port = 5072;
    document-root = "/export";
    extraConfig = ''
      server.dir-listing = "enable"
      server.follow-symlinks = "enable"
    '';
  };

  # --- syncthing ---
  services.syncthing = {
    enable = true;
    openDefaultPorts = false;
    guiAddress = "0.0.0.0:8384";
  };

  # --- seaweedfs ---
  containered-services.seaweedfs-master = {
    enable = true;
    dataDir = "/mnt/pstore1/seaweedfs/master";
  };
  containered-services.seaweedfs-node = {
    enable = true;
    volumes = [
      "/mnt/pstore0/seaweedfs/volume"
      "/mnt/pstore1/seaweedfs/volume"
    ];
  };

  system.stateVersion = "21.11";
}
