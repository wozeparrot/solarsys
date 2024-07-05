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
    firewall.allowedUDPPorts = [
      5353 # avahi
    ];
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
          8000 # mpd stream
          8384 # syncthing
          29999 # extra

          10001 # roc
          10002 # roc

          47984 # sunshine
          47989 # sunshine
          48010 # sunshine
        ];
        allowedUDPPorts = [
          29999 # extra

          10001 # roc
          10002 # roc

          47998 # sunshine
          47999 # sunshine
          48000 # sunshine
          48002 # sunshine
        ];
      };
    in {
      orion-away = fw_config;
      orion-home = fw_config;
    };

    # block certain hosts
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
