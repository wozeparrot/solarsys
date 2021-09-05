{ pkgs, ... }: {
  networking.hostName = "anime-nas";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  networking.firewall.allowedUDPPorts = [ 1400 ];

  networking.wg-quick.interfaces.wg0 = {
    address = [ "fdbe:ef11:2358:1321::1/64" ];
    listenPort = 1400;

    privateKeyFile = "/run/keys/wg_private";
  };

  system.stateVersion = "21.11";
}
