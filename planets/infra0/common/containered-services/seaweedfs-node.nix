{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.containered-services.seaweedfs-node;
in {
  options.containered-services.seaweedfs-node = {
    enable = mkEnableOption "seaweedfs volume server";

    bindAddress = mkOption {
      type = types.str;
      default = "10.11.235.1";
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
      default = [];
      description = "List of directories to start volume servers in";
    };
  };

  config = mkIf cfg.enable {
    # oneshot service to ensure that the volume directories exist
    systemd.services.seaweedfs-volume-setup = {
      description = "seaweedfs volume setup";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.coreutils}/bin/mkdir -p ${lib.concatStringsSep " " cfg.volumes}
        '';
      };

      after = ["network.target"];
      wantedBy = ["multi-user.target"];
    };

    containers.seaweedfs-node = {
      autoStart = true;
      ephemeral = true;

      bindMounts = lib.foldl' (cur: acc:
        cur
        // {
          "/mnt/seaweedfs-${toString acc}" = {
            hostPath = elemAt cfg.volumes acc;
            isReadOnly = false;
          };
        }) {} (lib.range 0 ((length cfg.volumes) - 1));

      config = {cconfig, ...}: {
        systemd.services = lib.foldl' (cur: acc:
          cur
          // {
            "seaweedfs-volume-${toString acc}" = {
              description = "seaweedfs volume server for ${elemAt cfg.volumes acc}";

              serviceConfig = {
                ExecStart = "${pkgs.master.seaweedfs}/bin/weed volume -ip ${cfg.bindAddress} -port ${toString (cfg.startPort + acc)} -mserver '${cfg.masterAddress}:${toString cfg.masterPort}' -max 0 -dir /mnt/seaweedfs-${toString acc}/";
              };

              after = ["network.target"];
              wantedBy = ["multi-user.target"];
            };
          }) {} (lib.range 0 ((length cfg.volumes) - 1));

        system.stateVersion = config.system.stateVersion;
      };
    };
    systemd.services."container@seaweedfs-node".after = ["seaweedfs-volume-setup.service" "container@seaweedfs-master.service"];
  };
}
