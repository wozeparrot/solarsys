{ lib, ... }: {
  networking = {
    networkmanager = {
      enable = true;
      dhcp = "dhcpcd";
      dns = "systemd-resolved";
      wifi.backend = "iwd";
    };
    wireless.iwd.enable = true;

    firewall.enable = true;
    firewall.allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    firewall.allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

  services.resolved.enable = true;

  users.users.woze.extraGroups = [ "networkmanager" ];
}
