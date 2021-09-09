{ ... }: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "internal";
      dns = "default";
      wifi.backend = "iwd";
    };
    wireless.iwd.enable = true;

    resolvconf.enable = true;

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

  users.users.woze.extraGroups = [ "networkmanager" ];
}
