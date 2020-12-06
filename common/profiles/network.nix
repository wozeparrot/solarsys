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
  };

  services.resolved.enable = true;
}
