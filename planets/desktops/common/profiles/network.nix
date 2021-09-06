{ ... }: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "internal";
      dns = "none";
      wifi.backend = "iwd";
    };
    wireless.iwd.enable = true;

    dhcpcd.extraConfig = "nohook resolv.conf";
    resolvconf.useLocalResolver = true;
    nameservers = [ "127.0.0.1" "::1" ];

    firewall.enable = true;
    firewall.allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
      { from = 29999; to = 29999; }
    ];
    firewall.allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
      { from = 29999; to = 29999; }
    ];
  };

  services.resolved.enable = false;
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  users.users.woze.extraGroups = [ "networkmanager" ];
}
