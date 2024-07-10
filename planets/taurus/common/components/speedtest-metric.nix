{
  lib,
  config,
  pkgs,
  ...
}:
let
  orion = import ../../../../networks/orion.nix;
  cfg = config.components.speedtest-metric;
in
{
  options.components.speedtest-metric = {
    enable = lib.mkEnableOption "speedtest metric exporter";
    bindAddress = lib.mkOption {
      type = lib.types.str;
      default =
        (lib.lists.findFirst (
          x: x.hostname == config.networking.hostName
        ) (builtins.abort "failed to find node in network") orion).address;
      description = "The address to bind the speedtest metric exporter to";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [ 9020 ];

    users.users.speedtest-metric = {
      isSystemUser = true;
      description = "Speedtest metric exporter";
      group = "speedtest-metric";
    };
    users.groups.speedtest-metric = { };

    systemd.services."prometheus-speedtest-metric" = {
      description = "Prometheus speedtest metric exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = [ pkgs.ookla-speedtest ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.ss.speedtest-exporter}/bin/speedtest-exporter \
            --bind="${cfg.bindAddress}:9020" \
        '';
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        User = "speedtest-metric";
        Group = "speedtest-metric";
      };
    };
  };
}
