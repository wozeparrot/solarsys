{
  config,
  pkgs,
  lib,
  ...
}: let
  orion = import ../../../../networks/orion.nix;
  isHub = (lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) {hostname = null;} orion).hostname == config.networking.hostName;
in {
  networking.firewall.allowedUDPPorts = [5553 5554];

  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = isHub;
  networking.wireguard.interfaces.orion = {
    ips = ["${(lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address}/24"];
    listenPort = 5553;

    privateKeyFile = "/keys/wg_private";

    peers =
      lib.lists.optionals isHub
      (map (x: {
          publicKey = x.pubkey;
          endpoint = x.endpoint;
          allowedIPs = ["${x.address}/32"];
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && (lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) []
        orion));

    postSetup = lib.optional isHub ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i orion -o orion -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.11.235.0/24 -o orion -j MASQUERADE
    '';
    postShutdown = lib.optional isHub ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i orion -o orion -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.11.235.0/24 -o orion -j MASQUERADE
    '';
  };
  services.wgautomesh = {
    enable = true;
    settings = {
      interface = "orion";
      gossip_port = 5554;
      peers =
        map (x: {
          inherit (x) address pubkey endpoint;
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && !(lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) []
        orion);
    };
    gossipSecretFile = "/keys/wgam_gossip_secret";
  };
}
