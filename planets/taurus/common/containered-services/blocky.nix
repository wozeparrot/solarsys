{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.containered-services.blocky;
in {
  options.containered-services.blocky = {
    enable = mkEnableOption "blocky dns proxy/adblocker";
    bindAddress = mkOption {
      type = types.str;
      default = "10.11.235.22";
      description = "IP address to bind to";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [
      53
      4000
    ];
    networking.firewall.interfaces.orion.allowedUDPPorts = [
      53
    ];

    containers.blocky = {
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

      # bind mounts
      bindMounts = {
        "/keys" = {
          hostPath = "/keys";
          isReadOnly = true;
        };
      };

      config = {cconfig, ...}: {
        # mount seaweedfs
        systemd.services."seaweedfs-mount" = {
          description = "mount seaweedfs for/in container";

          path = with pkgs; [fuse3];

          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/blocky";
            ExecStart = "${pkgs.seaweedfs}/bin/weed -v=2 mount -dir /var/lib/blocky -filer.path /services/blocky -filer=10.11.235.1:9302";
            ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/blocky; do sleep 1; done'";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target"];
          before = ["blocky.service"];
          wantedBy = ["multi-user.target"];
        };

        services.blocky = {
          enable = true;
          settings = {
            ports = {
              dns = "${cfg.bindAddress}:53";
              http = "${cfg.bindAddress}:4000";
              # tls = "${cfg.bindAddress}:853";
              # https = "${cfg.bindAddress}:443";
            };
            upstreams = {
              groups = {
                default = [
                  "https://cloudflare-dns.com/dns-query"
                  "tcp-tls:one.one.one.one:853"
                  "https://dns10.quad9.net/dns-query"
                  "tcp-tls:dns10.quad9.net:853"
                  "https://anycast.uncensoreddns.org/dns-query"
                  "1.1.1.1"
                ];
              };
            };
            blocking = {
              blackLists = {
                ads = [
                  "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                ];
              };
              clientGroupsBlock = {
                default = [
                  "ads"
                ];
              };
            };
            caching = {
              minTime = "5m";
            };
            prometheus = {
              enable = true;
            };
            queryLog = {
              type = "csv";
              target = "/var/lib/blocky";
            };
          };
        };
        systemd.services."blocky".serviceConfig.DynamicUser = lib.mkForce false;

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
