{
  lib,
  config,
  pkgs,
  ...
}:
let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.nextcloud;
in
{
  options.containered-services.nextcloud = {
    enable = lib.mkEnableOption "nextcloud";
    bindAddress = lib.mkOption {
      type = lib.types.str;
      default =
        (lib.lists.findFirst (
          x: x.hostname == config.networking.hostName
        ) (builtins.abort "failed to find node in network") orion).address;
      description = "IP address to bind to";
    };
    extraTrustedDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "192.168.0.194"
        "192.168.2.31"
      ];
      description = "Extra trusted domains";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 ];

    containers.nextcloud = {
      autoStart = true;
      ephemeral = true;
      timeoutStartSec = "12hr";

      # make fuse work
      allowedDevices = [
        {
          modifier = "rwm";
          node = "/dev/fuse";
        }
      ];
      additionalCapabilities = [ "CAP_MKNOD" ];
      extraFlags = [ "--bind=/dev/fuse" ];

      # bind mounts
      bindMounts = {
        "/keys" = {
          hostPath = "/keys";
          isReadOnly = true;
        };
      };

      config =
        { cconfig, ... }:
        rec {
          # mount seaweedfs
          systemd.services."seaweedfs-mount" = {
            description = "mount seaweedfs for/in container";

            path = with pkgs; [ fuse3 ];

            serviceConfig = {
              ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/nextcloud";
              ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed mount -dir /var/lib/nextcloud -filer.path /services/nextcloud -filer=10.11.235.1:9302";
              ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/nextcloud; do sleep 1; done'";
              Restart = "on-failure";
              RestartSec = "10s";
            };

            after = [ "network.target" ];
            before = [ "nextcloud-setup.service" ];
            wantedBy = [ "multi-user.target" ];
          };

          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud28;
            hostName = cfg.bindAddress;

            phpOptions = {
              catch_workers_output = "yes";
              display_errors = "stderr";
              error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
              expose_php = "Off";
              "opcache.enable_cli" = "1";
              "opcache.fast_shutdown" = "1";
              "opcache.interned_strings_buffer" = "8";
              "opcache.max_accelerated_files" = "10000";
              "opcache.memory_consumption" = "128";
              "opcache.revalidate_freq" = "60";
              "opcache.save_comments" = "1";
              "opcache.jit" = "1255";
              "opcache.jit_buffer_size" = "128M";
              "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
              short_open_tag = "Off";
            };

            home = "/var/lib/nextcloud/nextcloud";
            appstoreEnable = false;
            extraApps = with services.nextcloud.package.packages.apps; {
              inherit notes;
            };
            extraAppsEnable = true;

            configureRedis = true;
            caching.apcu = true;

            config = {
              adminuser = "root";
              adminpassFile = "/keys/nextcloud_adminpass";

              dbtype = "sqlite";
            };
            settings = {
              trusted_domains = cfg.extraTrustedDomains;
              default_phone_region = "CA";

              preview_max_x = 1024;
              preview_max_y = 1024;
            };
          };

          # don't persist redis
          services.redis.servers.nextcloud.save = [ ];

          system.stateVersion = config.system.stateVersion;
        };
    };
  };
}
