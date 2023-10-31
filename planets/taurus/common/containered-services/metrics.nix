{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.containered-services.metrics;
in {
  options.containered-services.metrics = {
    enable = mkEnableOption "metrics collection and visualization";
    addr = mkOption {
      type = types.str;
      default = "10.11.235.1";
      description = "IP address to bind to";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [3000 9090];

    containers.metrics = {
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
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/metrics";
            ExecStart = "${pkgs.seaweedfs}/bin/weed -v=2 mount -dir /var/lib/metrics -filer.path /services/metrics -filer=10.11.235.1:9302";
            ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/metrics; do sleep 1; done'";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = ["network.target"];
          before = ["grafana.service" "prometheus.service"];
          wantedBy = ["multi-user.target"];
        };

        # grafana
        services.grafana = {
          enable = true;
          dataDir = "/var/lib/metrics/grafana";
          declarativePlugins = [];
          settings = {
            server = {
              http_addr = cfg.addr;
              http_port = 3000;

              domain = cfg.addr;

              enable_gzip = true;
            };
            security = {
              secret_key = "$__file{/keys/grafana_secret_key}";
            };
            panels = {
              disable_sanitize_html = true;
            };
            analytics.reporting_enabled = false;
          };
        };

        # prometheus
        services.prometheus = {
          enable = true;
          # stateDir = "metrics/prometheus";
          listenAddress = cfg.addr;
          port = 9090;

          globalConfig = {
            scrape_interval = "10s";
            scrape_timeout = "8s";
            evaluation_interval = "30s";
          };

          scrapeConfigs = [
            {
              job_name = "seaweedfs-master";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["containered-services" "seaweedfs-master"] cc && cc.containered-services.seaweedfs-master.enable
                    then
                      acc
                      ++ [
                        "${cc.containered-services.seaweedfs-master.bindAddress}:${toString (cc.containered-services.seaweedfs-master.masterPort + 20000)}"
                      ]
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
            {
              job_name = "seaweedfs-filer";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["containered-services" "seaweedfs-master"] cc && cc.containered-services.seaweedfs-master.enable
                    then
                      acc
                      ++ [
                        "${cc.containered-services.seaweedfs-master.bindAddress}:${toString (cc.containered-services.seaweedfs-master.filerPort + 20000)}"
                      ]
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
            {
              job_name = "seaweedfs-volume";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["containered-services" "seaweedfs-node"] cc && cc.containered-services.seaweedfs-node.enable
                    then
                      acc
                      ++ (lib.lists.foldl' (
                        acc2: cur2:
                          acc2
                          ++ ["${cc.containered-services.seaweedfs-node.bindAddress}:${toString (cc.containered-services.seaweedfs-node.startPort + cur2 + 20000)}"]
                      ) [] (lib.range 0 ((length cc.containered-services.seaweedfs-node.volumes) - 1)))
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
            {
              job_name = "node";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["services" "prometheus" "exporters" "node"] cc && cc.services.prometheus.exporters.node.enable
                    then
                      acc
                      ++ [
                        "${cc.services.prometheus.exporters.node.listenAddress}:${toString cc.services.prometheus.exporters.node.port}"
                      ]
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
            {
              job_name = "wireguard";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["services" "prometheus" "exporters" "wireguard"] cc && cc.services.prometheus.exporters.wireguard.enable
                    then
                      acc
                      ++ [
                        "${cc.services.prometheus.exporters.wireguard.listenAddress}:${toString cc.services.prometheus.exporters.wireguard.port}"
                      ]
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
            {
              job_name = "blocky";
              static_configs = [
                {
                  targets = lib.lists.foldl' (acc: cur: let
                    cc = cur.core.config;
                  in
                    if lib.attrsets.hasAttrByPath ["containered-services" "blocky"] cc && cc.containered-services.blocky.enable
                    then
                      acc
                      ++ [
                        "${cc.containered-services.blocky.bindAddress}:4000"
                      ]
                    else acc) []
                  (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                }
              ];
            }
          ];
        };

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
