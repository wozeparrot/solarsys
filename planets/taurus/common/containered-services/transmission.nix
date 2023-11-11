{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.transmission;
in {
  options.containered-services.transmission = {
    enable = mkEnableOption "transmission torrent client";
    addr = mkOption {
      type = types.str;
      default = (lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address;
      description = "IP address to bind to";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [9091];

    containers.transmission = {
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
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/transmission";
            ExecStart = "${pkgs.seaweedfs}/bin/weed -v=2 mount -dir /var/lib/transmission -filer.path /services/transmission -filer=10.11.235.1:9302 -concurrentWriters 4";
            ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/transmission; do sleep 1; done'";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target"];
          before = ["transmission.service"];
          wantedBy = ["multi-user.target"];
        };

        services.transmission = {
          enable = true;
          settings = {
            rpc-bind-address = cfg.addr;
            rpc-port = 9091;
            rpc-whitelist = "10.11.235.*";
            rpc-whitelist-enabled = true;

            max-peers-global = 300;
            peer-limit-global = 300;
            peer-limit-per-torrent = 60;

            download-queue-size = 5;
            download-queue-enabled = true;

            idle-seeding-limit = 1;
            idle-seeding-limit-enabled = true;

            ratio-limit = 0;
            ratio-limit-enabled = true;

            speed-limit-up = 0;
            speed-limit-up-enabled = true;

            blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
            blocklist-enabled = true;

            encryption = 2;

            preallocation = 2;
            umask = 0;
          };
        };
        # TODO: https://github.com/NixOS/nixpkgs/issues/258793
        systemd.services.transmission.serviceConfig.BindReadOnlyPaths = lib.mkForce [ builtins.storeDir "/etc" ];

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
