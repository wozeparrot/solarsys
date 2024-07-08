{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.samba;
in {
  options.containered-services.samba = {
    enable = mkEnableOption "samba server";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      139
      445
      5357
    ];
    networking.firewall.allowedUDPPorts = [
      137
      138
      3702
    ];

    containers.samba = {
      autoStart = true;
      ephemeral = true;

      # make fuse work
      allowedDevices = [
        {
          modifier = "rwm";
          node = "/dev/fuse";
        }
      ];
      additionalCapabilities = [
        "CAP_MKNOD"
      ];
      extraFlags = [
        "--bind=/dev/fuse"
      ];

      config = {cconfig, ...}: {
        # mount seaweedfs
        systemd.services."seaweedfs-mount" = {
          description = "mount seaweedfs for/in container";

          path = with pkgs; [fuse3];

          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/samba-mount";
            ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed mount -dir /var/lib/samba-mount -filer.path /personal/family -filer=10.11.235.1:9302";
            ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/samba-mount; do sleep 1; done'";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target"];
          before = ["samba.service"];
          wantedBy = ["multi-user.target"];
        };

        services.samba = {
          enable = true;
          package = pkgs.sambaFull;
          securityType = "user";
          extraConfig = ''
            workgroup = SOLARSYS
            server string = ssmb
            netbios name = ssmb
            hosts allow = 10.11.235. 192.168.0. 127.0.0.1 localhost
            hosts deny = 0.0.0.0/0
            guest account = nobody
            map to guest = bad user
          '';
          shares = {
            family = {
              path = "/var/lib/samba-mount";
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = "username";
              "force group" = "groupname";
            };
          };
        };

        services.samba-wsdd = {
          enable = true;
          workgroup = "SOLARSYS";
          hostname = "ssmb";
        };

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
