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
        users.users.family.isNormalUser = true;
        users.users.family.group = "family";
        users.groups.family = {};

        # mount seaweedfs
        systemd.services."seaweedfs-mount" = {
          description = "mount seaweedfs for/in container";

          path = with pkgs; [fuse3];

          serviceConfig = {
            ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/mkdir -p /var/lib/samba-mount; ${pkgs.coreutils}/bin/chown family:family /var/lib/samba-mount'";
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
          enableNmbd = true;
          package = pkgs.sambaFull;
          securityType = "user";
          extraConfig = ''
            workgroup = SOLARSYS
            server string = ssmb
            netbios name = ssmb
            security = user
            hosts allow = 10.11.235.0/24 192.168.0.0/24 127.0.0.1 localhost
            hosts deny = 0.0.0.0/0
            map to guest = bad user
          '';
          shares = {
            family = {
              path = "/var/lib/samba-mount";
              browseable = "yes";
              "read only" = "no";
              writeable = "yes";
              "guest ok" = "no";
              "force user" = "family";
              "force group" = "family";
            };
          };
        };

        services.samba-wsdd = {
          enable = true;
          workgroup = "SOLARSYS";
          hostname = "ssmb";
          interface = "eth0";
          extraOptions = ["--verbose"];
        };

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
