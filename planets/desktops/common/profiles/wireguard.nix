{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wireguard-tools
    dsvpn
  ];
  networking.firewall.checkReversePath = false;
}
