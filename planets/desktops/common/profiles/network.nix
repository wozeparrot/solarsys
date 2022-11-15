_: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "systemd-resolved";
      wifi.backend = "iwd";
    };
    wireless.iwd.enable = true;

    resolvconf.enable = false;

    firewall.enable = true;
    firewall.allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
      {
        from = 29999;
        to = 29999;
      }
    ];
    firewall.allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
      {
        from = 29999;
        to = 29999;
      }
    ];

    hosts = {
      "0.0.0.0" = [
        "sg-public-data-api.hoyoverse.com"
        "log-upload-os.hoyoverse.com"
        "overseauspider.yuanshen.com"
      ];
    };
  };

  services.resolved.enable = true;

  users.users.woze.extraGroups = ["networkmanager"];
}
