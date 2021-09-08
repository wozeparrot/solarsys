{ pkgs, ... }: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- packages ---
  environment.systemPackages = with pkgs; [
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

      harden-glue = true;

      harden-dnssec-stripped = true;

      use-caps-for-id = false;

      edns-buffer-size = 1472;

      prefetch = true;

      num-threads = 1;

      so-rcvbuf = "1m";

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
  networking.firewall.allowedUDPPorts = [ 53 5553 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
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

  system.stateVersion = "21.11";
}
