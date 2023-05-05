{pkgs, ...}: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/containered-services/seaweedfs-master.nix
    ../common/containered-services/seaweedfs-node.nix
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
      5314 # n2n
    ];
    allowedTCPPorts = [
      5072 # aninarr web dir
      5314 # n2n

      443 # caddy
      80 # acme
    ];
    interfaces.wg0 = {
      allowedUDPPorts = [
        53 # dns

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
        53 # dns

        8384 # syncthing
        22000

        9091 # transmission

        111 # nfs
        2049
        4000
        4001
        4002
        20048

        5070 # aninarr
        5071 # aninarrh
        5072 # aninarr web dir

        # seaweedfs
        9301
        19301
        9302
        19302
        9311
        19311
        9312
        19312

        443 # caddy
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [n2n.n2n];

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  # --- wireguard vpn setup ---
  # enable nat
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = ["wg0" "n2n0"];
  };

  # dns
  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    settings = {
      server = {
        interface = ["0.0.0.0" "::0"];
        access-control = [
          "0.0.0.0/0 refuse"
          "::/0 refuse"
          "10.11.235.0/24 allow"
          "fdbe:ef11:2358:1321::/64 allow"
          "10.13.141.0/24 allow"
          "127.0.0.0/8 allow"
          "::1 allow"
        ];

        do-ip4 = true;
        do-udp = true;
        do-tcp = true;

        do-ip6 = true;
        prefer-ip6 = false;

        harden-glue = true;

        harden-dnssec-stripped = true;

        use-caps-for-id = false;

        edns-buffer-size = 1472;

        prefetch = true;

        num-threads = 1;

        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
        ];

        local-data = [
          "\"wonest.duckdns.org A 10.11.235.1\""
        ];
      };
    };
  };

  # set sysctl for ipv6
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # define wireguard interface
  networking.wg-quick.interfaces.wg0 = {
    address = ["10.11.235.1/24" "fdbe:ef11:2358:1321::1/64"];
    listenPort = 5553;

    privateKeyFile = "/keys/wg_private";

    postUp = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.11.235.1/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE
    '';

    preDown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.11.235.1/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE
    '';

    peers = [
      {
        # woztop
        publicKey = "3U2Nu7UvYIzOHPLjwKCB5iQzSNO+6hL4fTvZ+AhGHT4=";
        allowedIPs = ["10.11.235.99/32" "fdbe:ef11:2358:1321::99/128"];
      }
      {
        # wone
        publicKey = "DNY6opgAbjMJh8o4O7h9dXiO4BCzg+0RM4zVNvQg3xs=";
        allowedIPs = ["10.11.235.88/32" "fdbe:ef11:2358:1321::88/128"];
      }
      {
        # x86runner0
        publicKey = "XM6CRHIBPyAvCs8VYUmPkgT8bwX32tXnwRZJp9ztMFg=";
        allowedIPs = ["10.11.235.11/32" "fdbe:ef11:2358:1321::11/128"];
      }
      {
        # x86runner1
        publicKey = "EYBKX22REQWG5VmC9VeXhiwvH6Gr2FTQ35m4TDQ9Fh0=";
        allowedIPs = ["10.11.235.12/32" "fdbe:ef11:2358:1321::12/128"];
      }
      {
        # aaaa
        publicKey = "seZ+gvU58blS9n8dMMws/7yNMXjGVjk2Sj18zDEKBW4=";
        allowedIPs = ["10.11.235.89/32" "fdbe:ef11:2358:1321::89/128"];
      }
    ];
  };

  # --- n2n setup ---
  systemd.services.n2n-supernode = {
    enable = true;

    serviceConfig = {
      ExecStart = "${pkgs.n2n.n2n}/bin/supernode /keys/n2n-supernode.conf";
      User = "root";
      Group = "root";
    };

    after = ["network.target"];
    wantedBy = ["multi-user.target"];
  };

  systemd.services.n2n-edge = {
    enable = true;

    postStart = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.13.141.1/24 -o eth0 -j MASQUERADE
    '';

    postStop = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.13.141.1/24 -o eth0 -j MASQUERADE
    '';

    serviceConfig = {
      ExecStart = "${pkgs.n2n.n2n}/bin/edge /keys/n2n-edge.conf";
      User = "root";
      Group = "root";
    };

    after = ["network.target" "n2n-supernode.service"];
    wantedBy = ["multi-user.target"];
  };

  # --- weechat ---
  services.weechat = {
    enable = true;
    binary = "${pkgs.master.weechat}/bin/weechat";
  };

  # --- transmission ---
  services.transmission = {
    enable = true;
    settings = {
      bind-address-ipv4 = "10.11.235.1";
      bind-address-ipv6 = "fdbe:ef11:2358:1321::1";

      rpc-bind-address = "::";
      rpc-port = 9091;
      rpc-whitelist-enabled = false;

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
    dataDir = "/mnt/pstore1/seaweedfs";
  };
  containered-services.seaweedfs-node = {
    enable = true;
    volumes = [
      "/mnt/pstore0/seaweedfs/volume"
      "/mnt/pstore1/seaweedfs/volume"
    ];
  };

  # --- caddy ---
  containers.caddy = {
    autoStart = false;
    ephemeral = true;

    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];

    additionalCapabilities = [
      "CAP_MKNOD"
    ];

    extraFlags = [
      "--bind=/dev/fuse"
    ];

    config = {config, ...}: {
      # mount seaweedfs
      systemd.services."seaweedfs-mount" = {
        description = "mount seaweedfs for/in container";

        path = with pkgs; [fuse3];

        serviceConfig = {
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/caddy";
          ExecStart = "${pkgs.seaweedfs}/bin/weed mount -dir /var/lib/caddy -filer.path /services/caddy -filer=10.11.235.1:9302";
          ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
          Restart = "on-failure";
          RestartSec = "10s";
        };

        after = ["network.target"];
        before = ["caddy.target"];
        wantedBy = [
          "multi-user.target"
          "caddy.target"
        ];
      };

      services.caddy = {
        enable = true;
        virtualHosts = {
          # "ak.enqy.one" = {
          #   extraConfig = ''
          #     reverse_proxy :7320
          #   '';
          # };
        };
      };
      systemd.services."caddy" = {
        after = ["seaweedfs-mount.service"];
      };

      system.stateVersion = "22.11";
    };
  };

  system.stateVersion = "21.11";
}
