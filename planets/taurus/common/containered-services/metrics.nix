{
  lib,
  config,
  pkgs,
  ...
}:
let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.metrics;
in
{
  options.containered-services.metrics = {
    enable = lib.mkEnableOption "metrics collection and visualization";
    addr = lib.mkOption {
      type = lib.types.str;
      default =
        (lib.lists.findFirst (
          x: x.hostname == config.networking.hostName
        ) (builtins.abort "failed to find node in network") orion).address;
      description = "IP address to bind to";
    };
    promLocalPath = lib.mkOption {
      type = lib.types.str;
      description = "path to local prometheus storage";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces.orion.allowedTCPPorts = [
      # grafana
      3000
      # prometheus
      9090
      # loki
      3100
      13100
    ];

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
      additionalCapabilities = [ "CAP_MKNOD" ];
      extraFlags = [ "--bind=/dev/fuse" ];

      # bind mounts
      bindMounts = {
        "/keys" = {
          hostPath = "/keys";
          isReadOnly = true;
        };
        "/var/lib/prometheus2" = {
          hostPath = cfg.promLocalPath;
          isReadOnly = false;
        };
      };

      config =
        { cconfig, ... }:
        {
          # mount seaweedfs
          systemd.services."seaweedfs-mount" = {
            description = "mount seaweedfs for/in container";

            path = with pkgs; [ fuse3 ];

            serviceConfig = {
              ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/metrics";
              ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed -v=2 mount -dir /var/lib/metrics -filer.path /services/metrics -filer=10.11.235.1:9302";
              ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/metrics; do sleep 1; done'";
              Restart = "on-failure";
              RestartSec = "10s";
            };

            after = [ "network.target" ];
            before = [
              "grafana.service"
              "prometheus.service"
              "loki.service"
            ];
            wantedBy = [ "multi-user.target" ];
          };

          # grafana
          services.grafana = {
            enable = true;
            dataDir = "/var/lib/metrics/grafana";
            declarativePlugins = [ ];
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

          # loki
          services.loki = {
            enable = true;
            dataDir = "/var/lib/metrics/loki";
            configuration = {
              auth_enabled = false;
              common = {
                instance_addr = cfg.addr;
                path_prefix = "/var/lib/metrics/loki";
                storage = {
                  filesystem = {
                    chunks_directory = "/var/lib/metrics/loki/chunks";
                    rules_directory = "/var/lib/metrics/loki/rules";
                  };
                };
                replication_factor = 1;
                ring = {
                  kvstore = {
                    store = "inmemory";
                  };
                };
              };
              server = {
                http_listen_address = cfg.addr;
                http_listen_port = 3100;
                grpc_listen_address = cfg.addr;
                grpc_listen_port = 13100;
              };
              query_range = {
                results_cache = {
                  cache = {
                    embedded_cache = {
                      enabled = true;
                      max_size_mb = 100;
                    };
                  };
                };
              };
              schema_config = {
                configs = [
                  {
                    from = "2023-01-01";
                    store = "tsdb";
                    object_store = "filesystem";
                    schema = "v12";
                    index = {
                      prefix = "index_";
                      period = "24h";
                    };
                  }
                ];
              };
              analytics.reporting_enabled = false;
            };
          };

          # prometheus
          services.prometheus = {
            enable = true;
            stateDir = "prometheus2";
            listenAddress = cfg.addr;
            port = 9090;

            globalConfig = {
              scrape_interval = "10s";
              scrape_timeout = "8s";
              evaluation_interval = "10s";
            };

            scrapeConfigs = [
              {
                job_name = "node";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "services"
                          "prometheus"
                          "exporters"
                          "node"
                        ] cc
                        && cc.services.prometheus.exporters.node.enable
                      then
                        acc
                        ++ [
                          "${cc.services.prometheus.exporters.node.listenAddress}:${toString cc.services.prometheus.exporters.node.port}"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "wireguard";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "services"
                          "prometheus"
                          "exporters"
                          "wireguard"
                        ] cc
                        && cc.services.prometheus.exporters.wireguard.enable
                      then
                        acc
                        ++ [
                          "${cc.services.prometheus.exporters.wireguard.listenAddress}:${toString cc.services.prometheus.exporters.wireguard.port}"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "smartctl";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "services"
                          "prometheus"
                          "exporters"
                          "smartctl"
                        ] cc
                        && cc.services.prometheus.exporters.smartctl.enable
                      then
                        acc
                        ++ [
                          "${cc.services.prometheus.exporters.smartctl.listenAddress}:${toString cc.services.prometheus.exporters.smartctl.port}"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "promtail";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "services"
                          "promtail"
                        ] cc
                        && cc.services.promtail.enable
                      then
                        acc
                        ++ [
                          "${cc.services.promtail.configuration.server.http_listen_address}:${toString cc.services.promtail.configuration.server.http_listen_port}"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "seaweedfs-master";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "containered-services"
                          "seaweedfs-master"
                        ] cc
                        && cc.containered-services.seaweedfs-master.enable
                      then
                        acc
                        ++ [
                          "${cc.containered-services.seaweedfs-master.bindAddress}:${
                            toString (cc.containered-services.seaweedfs-master.masterPort + 20000)
                          }"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "seaweedfs-filer";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "containered-services"
                          "seaweedfs-master"
                        ] cc
                        && cc.containered-services.seaweedfs-master.enable
                      then
                        acc
                        ++ [
                          "${cc.containered-services.seaweedfs-master.bindAddress}:${
                            toString (cc.containered-services.seaweedfs-master.filerPort + 20000)
                          }"
                        ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "seaweedfs-volume";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "containered-services"
                          "seaweedfs-node"
                        ] cc
                        && cc.containered-services.seaweedfs-node.enable
                      then
                        acc
                        ++ (lib.lists.foldl' (
                          acc2: cur2:
                          acc2
                          ++ [
                            "${cc.containered-services.seaweedfs-node.bindAddress}:${
                              toString (cc.containered-services.seaweedfs-node.startPort + cur2 + 20000)
                            }"
                          ]
                        ) [ ] (lib.range 0 ((lib.length cc.containered-services.seaweedfs-node.volumes) - 1)))
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "blocky";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "containered-services"
                          "blocky"
                        ] cc
                        && cc.containered-services.blocky.enable
                      then
                        acc ++ [ "${cc.containered-services.blocky.bindAddress}:4000" ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
                  }
                ];
              }
              {
                job_name = "speedtest";
                static_configs = [
                  {
                    targets = lib.lists.foldl' (
                      acc: cur:
                      let
                        cc = cur.core.config;
                      in
                      if
                        lib.attrsets.hasAttrByPath [
                          "components"
                          "speedtest-metric"
                        ] cc
                        && cc.components.speedtest-metric.enable
                      then
                        acc ++ [ "${cc.components.speedtest-metric.bindAddress}:9020" ]
                      else
                        acc
                    ) [ ] (lib.attrsets.mapAttrsToList (_: v: v) config.solarsys.moons);
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
