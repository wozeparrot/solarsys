{ ... }: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "systemd-resolved";
      wifi.backend = "iwd";
    };
    wireless.iwd.enable = true;

    firewall.enable = false;
    firewall.allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
      { from = 29999; to = 29999; }
    ];
    firewall.allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
      { from = 29999; to = 29999; }
    ];
  };

  services.resolved.enable = true;

  users.users.woze.extraGroups = [ "networkmanager" ];
}
