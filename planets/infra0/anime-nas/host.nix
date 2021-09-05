{ pkgs, ... }: {
  networking.hostName = "anime-nas";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  networking.firewall.allowedUDPPorts = [ 5553 ];

  networking.wg-quick.interfaces.wg0 = {
    address = [ "fdbe:ef11:2358:1321::1/64" ];
    listenPort = 5553;

    privateKeyFile = "/run/keys/wg_private";
  };

  system.stateVersion = "21.11";
}
