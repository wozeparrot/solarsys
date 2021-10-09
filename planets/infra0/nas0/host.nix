{ pkgs, ... }: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- mount disks --- 
  fileSystems = {
    "/mnt/pstore0" = {
      device = "/dev/disk/by-uuid/7591e656-ea01-4841-a6e8-fcf585be0190";
      fsType = "ext4";
    };
    "/mnt/pstore1" = {
      device = "/dev/disk/by-uuid/823e9830-4af1-42cc-929c-05fcf078326c";
      fsType = "xfs";
    };
  };

  # --- open ports ---
  networking.firewall.allowedUDPPorts = [ 5553 ]; # only wireguard traffic
  networking.firewall.allowedTCPPorts = [
    5072 # aninarr web dir
  ];
  networking.firewall.interfaces.wg0 = {
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
    ];
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- wireguard vpn setup ---
  # enable nat
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  # dns
  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    settings.server = {
      interface = [ "0.0.0.0" "::0" ];
      access-control = [
        "0.0.0.0/0 refuse"
        "::/0 refuse"
        "10.11.235.0/24 allow"
        "fdbe:ef11:2358:1321::/64 allow"
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
    };
  };

  # set sysctl for ipv6
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # define wireguard interface
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.11.235.1/24" "fdbe:ef11:2358:1321::1/64" ];
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
        allowedIPs = [ "10.11.235.99/32" "fdbe:ef11:2358:1321::99/128" ];
      }
      {
        # wone
        publicKey = "DNY6opgAbjMJh8o4O7h9dXiO4BCzg+0RM4zVNvQg3xs=";
        allowedIPs = [ "10.11.235.88/32" "fdbe:ef11:2358:1321::88/128" ];
      }
    ];
  };

  # --- weechat ---
  services.weechat.enable = true;
  services.weechat.binary = "${pkgs.mpkgs.weechat}/bin/weechat";

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

  # --- nfs ---
  fileSystems."/export/music" = {
    device = "/mnt/pstore0/datas/sync/music";
    options = [ "bind" ];
  };
  fileSystems."/export/anime" = {
    device = "/mnt/pstore1/datas/aninarr/anime";
    options = [ "bind" ];
  };
  fileSystems."/export/store" = {
    device = "/mnt/pstore1/datas/aninarr/store";
    options = [ "bind" ];
  };
  fileSystems."/export/books" = {
    device = "/mnt/pstore0/datas/books";
    options = [ "bind" ];
  };
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /export               *(insecure,ro,no_root_squash,async,no_subtree_check,crossmnt,fsid=0)
      /export/music         *(insecure,ro,no_root_squash,async,no_subtree_check)
      /export/anime         *(insecure,ro,no_root_squash,async,no_subtree_check)
      /export/store         *(insecure,ro,no_root_squash,async,no_subtree_check)
      /export/books         *(insecure,ro,no_root_squash,async,no_subtree_check)
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

  # --- aninarr ---
  # aninarr
  systemd.services."aninarr" = {
    description = "aninarr daemon";

    path = with pkgs; [ bash ];
    serviceConfig = {
      ExecStart = "${pkgs.aninarr.aninarr}/bin/aninarr";
      WorkingDirectory = "/mnt/pstore1/datas/aninarr";
      Restart = "always";
      RestartSec = "5s";
      User = "root";
      Group = "root";
    };

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  # aninarrh
  systemd.services."aninarrh" = {
    description = "aninarrh daemon";

    serviceConfig = {
      ExecStart = "${pkgs.aninarr.aninarrh}/bin/aninarrh localhost 5071";
      WorkingDirectory = "${pkgs.aninarr.aninarrh}";
      StandardOutput = "inherit";
      StandardError = "inherit";
      Restart = "always";
      RestartSec = "5s";
    };

    after = [ "aninarr.service" ];
    wantedBy = [ "multi-user.target" ];
  };
  # aninarrx
  systemd.services."aninarrx" = {
    description = "aninarrx daemon";

    path = with pkgs; [ bash jq ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash helper.bash localhost yes";
      WorkingDirectory = "${pkgs.aninarr.aninarrx}";
      Restart = "always";
      RestartSec = "5s";
    };

    after = [ "aninarr.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  # --- wozey.service ---
  #systemd.services."wozey" = {
  #  description = "wozey.service daemon";

  #  serviceConfig = {
  #    ExecStart = "${pkgs.wozey.wozey}/bin/wozey";
  #    WorkingDirectory = "/tmp";
  #    Restart = "always";
  #    RestartSec = "5s";
  #  };

  #  after = [ "network.target" ];
  #  wantedBy = [ "multi-user.target" ];
  #};

  system.stateVersion = "21.11";
}
