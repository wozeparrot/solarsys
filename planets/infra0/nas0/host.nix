{ pkgs, ... }: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- wireguard vpn setup ---
  # set sysctl for ipv6
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # open ports
  networking.firewall.allowedUDPPorts = [ 5553 ];

  # define wireguard interface
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.11.235.1/24" "fdbe:ef11:2358:1321::1/64" ];
    listenPort = 5553;

    privateKeyFile = "/run/keys/wg_private";

    peers = [
      { # woztop
        publicKey = "3U2Nu7UvYIzOHPLjwKCB5iQzSNO+6hL4fTvZ+AhGHT4=";
        allowedIPs = [ "10.11.235.99/32" "fdbe:ef11:2358:1321::99/128" ];
      }
      { # wone
        publicKey = "DNY6opgAbjMJh8o4O7h9dXiO4BCzg+0RM4zVNvQg3xs=";
        allowedIPs = [ "10.11.235.88/32" "fdbe:ef11:2358:1321::88/128" ];
      }
    ];
  };

  system.stateVersion = "21.11";
}
