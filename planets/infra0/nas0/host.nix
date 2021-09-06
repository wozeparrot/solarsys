{ pkgs, ... }: {
  networking.hostName = "nas0";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- wireguard vpn setup ---
  # open ports
  networking.firewall.allowedUDPPorts = [ 5553 ];
  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  # enable nat for external access
  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInferfaces = [ "wg0" ];
  };

  # enable dns over wireguard
  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" "1.0.0.1" ];
    extraConfig = ''
      interface=wg0
    '';
  };

  # define wireguard interface
  networking.wg-quick.interfaces.wg0 = {
    address = [ "fdbe:ef11:2358:1321::1/64" ];
    listenPort = 5553;

    privateKeyFile = "/run/keys/wg_private";

    postUp = ''
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE
    '';

    preDown = ''
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdbe:ef11:2358:1321::1/64 -o eth0 -j MASQUERADE
    '';

    peers = [
      { # woztop
        publicKey = "3U2Nu7UvYIzOHPLjwKCB5iQzSNO+6hL4fTvZ+AhGHT4=";
        allowedIPs = [ "fdbe:ef11:2358:1321::99/128" ];
      }
      { # wone
        publicKey = "DNY6opgAbjMJh8o4O7h9dXiO4BCzg+0RM4zVNvQg3xs=";
        allowedIPs = [ "fdbe:ef11:2358:1321::88/128" ];
      }
    ];
  };

  system.stateVersion = "21.11";
}
