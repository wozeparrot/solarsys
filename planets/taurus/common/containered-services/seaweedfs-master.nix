{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.seaweedfs-master;
in {
  options.containered-services.seaweedfs-master = {
    enable = mkEnableOption "seaweedfs master & filer";
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/seaweedfs";
      description = "Directory to store data in";
    };
    bindAddress = mkOption {
      type = types.str;
      default = (lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address;
      description = "IP address to bind to";
    };
    masterPort = mkOption {
      type = types.int;
      default = 9301;
      description = "Port to bind master to";
    };
    filerPort = mkOption {
      type = types.int;
      default = 9302;
      description = "Port to bind filer to";
    };
    volumeSizeLimitMB = mkOption {
      type = types.int;
      default = 16384;
      description = "Maximum size of a volume in MB";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [
      cfg.masterPort
      (cfg.masterPort + 10000)
      (cfg.masterPort + 20000)
      cfg.filerPort
      (cfg.filerPort + 10000)
      (cfg.filerPort + 20000)
    ];

    containers.seaweedfs-master = {
      autoStart = true;
      ephemeral = true;

      bindMounts = {
        "/var/lib/seaweedfs" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
      };

      config = {cconfig, ...}: {
        # oneshot systemd service to create required directories
        systemd.services."seaweedfs-preinit" = {
          description = "Preinit stuff for seaweedfs";

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/mkdir -p /var/lib/seaweedfs/master/";
          };

          after = ["network.target"];
          wantedBy = ["multi-user.target"];
        };

        environment.etc."seaweedfs/master.toml".text = ''
          [master.maintenance]
          scripts = """
            lock
            volume.deleteEmpty -quietFor=24h -force
            volume.balance -force
            volume.fix.replication
            s3.clean.uploads -timeAgo=24h
            unlock
          """
          sleep_minutes = 17

          [master.sequencer]
          type = "raft"

          [master.volume_growth]
          copy_1 = 7
          copy_2 = 7
          copy_3 = 7
          copy_other = 7
        '';
        systemd.services."seaweedfs-master" = {
          description = "seaweedfs master server";

          serviceConfig = {
            ExecStart = "${pkgs.master.seaweedfs}/bin/weed master -ip ${cfg.bindAddress} -port ${toString cfg.masterPort} -mdir '/var/lib/seaweedfs/master/' -volumeSizeLimitMB=${toString cfg.volumeSizeLimitMB} -defaultReplication=010 -metricsPort ${toString (cfg.masterPort + 20000)}";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target" "seaweedfs-preinit.service"];
          wantedBy = ["multi-user.target"];
        };

        environment.etc."seaweedfs/filer.toml".text = ''
          [filer.options]
          recursive_delete = false

          [sqlite]
          enabled = true
          dbFile = "/var/lib/seaweedfs/filer.db"
        '';
        systemd.services."seaweedfs-filer" = {
          description = "seaweedfs filer server";

          serviceConfig = {
            ExecStart = "${pkgs.master.seaweedfs}/bin/weed filer -ip ${cfg.bindAddress} -port ${toString cfg.filerPort} -master '${cfg.bindAddress}:${toString cfg.masterPort}' -metricsPort ${toString (cfg.filerPort + 20000)}";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target" "seaweedfs-master.service" "seaweedfs-preinit.service"];
          wantedBy = ["multi-user.target"];
        };

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
