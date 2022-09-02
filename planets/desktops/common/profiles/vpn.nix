{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wireguard-tools
    mullvad
  ];

  networking.firewall.checkReversePath = "loose";

  services.mullvad-vpn.enable = true;
}
