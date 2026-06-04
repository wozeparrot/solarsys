{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ss.orion;
  orion = import ../../../../networks/orion.nix;
  isHub =
    (lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) { hostname = null; } orion).hostname
    == config.networking.hostName;
in
{
  options.ss.orion = {
    externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "WAN interface for NAT masquerade on the hub";
    };
  };

  config = {
    networking.firewall.allowedUDPPorts = [
      5553
      5554
    ];

    networking.firewall.checkReversePath = "loose";
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = isHub;

    networking.nat = lib.mkIf isHub {
      enable = true;
      internalInterfaces = [ "orion" ];
      externalInterface = cfg.externalInterface;
    };

    networking.wireguard.interfaces.orion = {
      ips = [
        "${
          (lib.lists.findFirst (
            x: x.hostname == config.networking.hostName
          ) (builtins.abort "failed to find node in network") orion).address
        }/24"
      ];
      listenPort = 5553;

      privateKeyFile = "/keys/wg_private";

      peers = lib.lists.optionals isHub (
        map
          (x: {
            publicKey = x.pubkey;
            allowedIPs = [ "${x.address}/32" ];
          })
          (
            lib.lists.foldl' (
              acc: cur:
              if cur.hostname != config.networking.hostName && (lib.strings.hasInfix "client" cur.type) then
                acc ++ [ cur ]
              else
                acc
            ) [ ] orion
          )
      );

      postSetup = lib.optional isHub ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i orion -o orion -j ACCEPT
      '';
      postShutdown = lib.optional isHub ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i orion -o orion -j ACCEPT
      '';
    };

  };
}
