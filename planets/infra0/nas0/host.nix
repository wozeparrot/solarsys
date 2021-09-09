{ pkgs, ... }: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- packages ---
  environment.systemPackages = with pkgs; [
    aninarr.aninarr
  ];

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

  # open ports
  networking.firewall.allowedUDPPorts = [ 5553 ];
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 
      53 # dns
      8080 # glowing-bear
      9001 # weechat
      9091 # transmission
    ];
    allowedTCPPorts = [
      53 # dns
      8080 # glowing-bear
      9001 # weechat
      9091 # transmission
    ];
  };

  # define wireguard interface
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.11.235.1/24" "fdbe:ef11:2358:1321::1/64" ];
    listenPort = 5553;

    privateKeyFile = "/run/keys/wg_private";

    postUp = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.11.235.1/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE
    '';

    preDown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.11.235.1/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE 
    '';

    peers = [
      { # woztop
        publicKey = "3U2Nu7UvYIzOHPLjwKCB5iQzSNO+6hL4fTvZ+AhGHT4=";
        allowedIPs = [ "10.11.235.99/32" "fdbe:ef11:2358:1321::99/128" ];
      }
      { # wone
        publicKey = "DNY6opgAbjMJh8o4O7h9dXiO4BCzg+0RM4zVNvQg3xs=";
        allowedIPs = [ "10.11.235.88/32" "fdbe:ef11:2358:1321::88/128" ];
      }
    ];
  };

  # --- weechat ---
  services.weechat.enable = true;
  services.darkhttpd = {
    enable = true;
    address = "all";
    port = 8080;
    rootDir = pkgs.glowing-bear;
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

      incomplete-dir-enabled = false;

      max-peers-global = 120;
      peer-limit-global = 120;
      peer-limit-per-torrent = 50;

      download-queue-size = 3;
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

  system.stateVersion = "21.11";
}
