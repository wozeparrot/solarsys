{
  lib,
  config,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.components.common-metrics;
in {
  options.components.common-metrics = {
    enable = mkEnableOption "common metrics exporters";
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [
      config.services.prometheus.exporters.node.port
      config.services.prometheus.exporters.wireguard.port
      config.services.prometheus.exporters.smartctl.port
    ];

    services.prometheus.exporters = let
      listenAddress = (lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address;
    in {
      node = {
        inherit listenAddress;
        enable = true;
        enabledCollectors = ["systemd"];
        port = 9001;
      };
      wireguard = {
        inherit listenAddress;
        enable = true;
        port = 9002;
      };
      smartctl = {
        inherit listenAddress;
        enable = true;
        port = 9003;
      };
    };
  };
}
