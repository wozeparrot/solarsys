{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "amateru";

  imports = [
    ../common/profiles/rpi4.nix
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
      5553 # wireguard
      5554 # wgautomesh
    ];
    allowedTCPPorts = [
    ];
    interfaces.orion = {
      allowedUDPPorts = [
        8384 # syncthing
        22000

        9091 # transmission

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

        9091 # transmission

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

  # --- wireguard setup ---
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = (lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) {hostname = null;} (import ../../../networks/orion.nix)).hostname == config.networking.hostName;
  networking.wireguard.interfaces.orion = {
    ips = ["${(lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") (import ../../../networks/orion.nix)).address}/24"];
    listenPort = 5553;

    privateKeyFile = "/keys/wg_private";

    peers =
      lib.lists.optionals ((lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) {hostname = null;} (import ../../../networks/orion.nix)).hostname == config.networking.hostName)
      (map (x: {
          publicKey = x.pubkey;
          endpoint = x.endpoint;
          allowedIPs = ["${x.address}/32"];
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && (lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) [] (import ../../../networks/orion.nix)));

    postSetup = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i orion -o orion -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.11.235.0/24 -o orion -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i orion -o orion -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.11.235.0/24 -o orion -j MASQUERADE
    '';
  };
  services.wgautomesh = {
    enable = true;
    settings = {
      interface = "orion";
      gossip_port = 5554;
      peers =
        map (x: {
          inherit (x) address pubkey endpoint;
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && !(lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) [] (import ../../../networks/orion.nix));
    };
    gossipSecretFile = "/keys/wgam_gossip_secret";
  };

  # --- metrics ---
  containered-services.metrics.enable = true;

  # --- transmission ---
  services.transmission = {
    enable = true;
    settings = {
      bind-address-ipv4 = "10.11.235.1";

      rpc-bind-address = "10.11.235.1";
      rpc-port = 9091;
      rpc-whitelist = "10.11.235.*";
      rpc-whitelist-enabled = true;

      download-dir = "/mnt/pstore1/tmps";
      incomplete-dir-enabled = false;

      max-peers-global = 200;
      peer-limit-global = 200;
      peer-limit-per-torrent = 50;

      download-queue-size = 4;
      download-queue-enabled = true;

      idle-seeding-limit = 1;
      idle-seeding-limit-enabled = true;

      ratio-limit = 0;
      ratio-limit-enabled = true;

      speed-limit-up = 0;
      speed-limit-up-enabled = true;

      blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
      blocklist-enabled = true;

      encryption = 2;
    };
  };

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
