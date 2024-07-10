{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.seaweedfs-node;
in
{
  options.containered-services.seaweedfs-node = {
    enable = mkEnableOption "seaweedfs volume server";

    bindAddress = mkOption {
      type = types.str;
      default =
        (lib.lists.findFirst (
          x: x.hostname == config.networking.hostName
        ) (builtins.abort "failed to find node in network") orion).address;
      description = "IP address to bind to";
    };
    startPort = mkOption {
      type = types.int;
      default = 9311;
      description = "Port to start binding to";
    };
    masterAddress = mkOption {
      type = types.str;
      default = "10.11.235.1";
      description = "IP address of the master server";
    };
    masterPort = mkOption {
      type = types.int;
      default = 9301;
      description = "Port of the master server";
    };

    volumes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of directories to start volume servers in";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = lib.foldl' (
      cur: acc:
      cur
      ++ [
        (cfg.startPort + acc)
        (cfg.startPort + acc + 10000)
        (cfg.startPort + acc + 20000)
      ]
    ) [ ] (lib.range 0 ((length cfg.volumes) - 1));

    # oneshot service to ensure that the volume directories exist
    systemd.services.seaweedfs-volume-setup = {
      description = "seaweedfs volume setup";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.coreutils}/bin/mkdir -p ${lib.concatStringsSep " " cfg.volumes}
        '';
      };

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    containers.seaweedfs-node = {
      autoStart = true;
      ephemeral = true;

      bindMounts = lib.lists.foldl' (
        acc: cur:
        acc
        // {
          "/mnt/seaweedfs-${toString cur}" = {
            hostPath = elemAt cfg.volumes cur;
            isReadOnly = false;
          };
        }
      ) { } (lib.range 0 ((length cfg.volumes) - 1));

      config =
        { cconfig, ... }:
        {
          systemd.services = lib.foldl' (
            acc: cur:
            acc
            // {
              "seaweedfs-volume-${toString cur}" = {
                description = "seaweedfs volume server for ${elemAt cfg.volumes cur}";

                serviceConfig = {
                  ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed volume -ip ${cfg.bindAddress} -port ${toString (cfg.startPort + cur)} -mserver '${cfg.masterAddress}:${toString cfg.masterPort}' -max 0 -dir /mnt/seaweedfs-${toString cur}/ -dataCenter='${config.solarsys.planet}' -rack='${config.networking.hostName}' -index=memory -metricsPort ${
                    toString (cfg.startPort + cur + 20000)
                  }";
                };

                after = [ "network.target" ];
                wantedBy = [ "multi-user.target" ];
              };
            }
          ) { } (lib.range 0 ((length cfg.volumes) - 1));

          system.stateVersion = config.system.stateVersion;
        };
    };
    systemd.services."container@seaweedfs-node".after = [
      "seaweedfs-volume-setup.service"
      "container@seaweedfs-master.service"
    ];
  };
}
