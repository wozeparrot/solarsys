{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
  networking.firewall.checkReversePath = false;
}
