{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    master.mullvad
  ];

  networking.firewall.checkReversePath = "loose";

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.master.mullvad;
}
