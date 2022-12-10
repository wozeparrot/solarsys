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

    firewall.interfaces = let
      fw_config = {
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          } # kdeconnect
        ];
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          } # kdeconnect
        ];
        allowedTCPPorts = [
          6600 # mpd
          29999 # extra
        ];
        allowedUDPPorts = [
          29999 # extra
        ];
      };
    in {
      solarsys-away = fw_config;
      solarsys-home = fw_config;
    };

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
