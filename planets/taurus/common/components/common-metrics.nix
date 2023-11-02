{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.components.common-metrics;
in {
  options.components.common-metrics = {
    enable = mkEnableOption "common metrics exporters";
  };

  config = let
    listenAddress = (lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address;
  in
    mkIf cfg.enable {
      networking.firewall.interfaces.orion.allowedTCPPorts = [
        config.services.prometheus.exporters.node.port
        config.services.prometheus.exporters.wireguard.port
        config.services.prometheus.exporters.smartctl.port
        config.services.promtail.configuration.server.http_listen_port
      ];

      services.prometheus.exporters = {
        node = {
          inherit listenAddress;
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9001;
        };
        wireguard = {
          inherit listenAddress;
          enable = true;
          port = 9002;
        };
        smartctl = {
          inherit listenAddress;
          enable = true;
          port = 9003;
        };
      };

      services.promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_address = listenAddress;
            http_listen_port = 9030;
            grpc_listen_address = listenAddress;
            grpc_listen_port = 19030;
          };
          clients = [
            {
              url = "http://10.11.235.1:3100/loki/api/v1/push";
            }
          ];
          scrape_configs =
            [
              {
                job_name = "journal";
                journal = {
                  max_age = "12h";
                  labels = {
                    job = "systemd-journal";
                    host = config.networking.hostName;
                    container = "host";
                  };
                };
                relabel_configs = [
                  {
                    source_labels = ["__journal__systemd_unit"];
                    target_label = "unit";
                  }
                ];
              }
            ]
            ++ lib.attrsets.foldlAttrs (acc: name: value:
              acc
              ++ [
                {
                  job_name = "journal-${name}";
                  journal = {
                    max_age = "12h";
                    labels = {
                      job = "systemd-journal";
                      host = config.networking.hostName;
                      container = name;
                    };
                    path = "/run/linked-container-journald/${name}/";
                  };
                  relabel_configs = [
                    {
                      source_labels = ["__journal__systemd_unit"];
                      target_label = "unit";
                    }
                  ];
                }
              ])
            []
            config.containers;
        };
      };

      # this is a hack to get the journals inside of containers readable by promtail
      systemd.services =
        {
          promtail.after = lib.attrsets.foldlAttrs (acc: name: value: acc ++ ["link-journald-${name}.service"]) [] config.containers;
        }
        // lib.attrsets.foldlAttrs (
          acc: name: value:
            acc
            // {
              "link-journald-${name}" = {
                description = "symlink ${name} container journald to known location";

                requires = ["container@${name}.service"];
                after = ["container@${name}.service"];
                bindsTo = ["container@${name}.service"];
                wantedBy = ["multi-user.target"];

                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  ExecStart = let
                    link-journald = pkgs.writeShellScriptBin "link-journald" ''
                      # get the root directory of the container
                      CONTAINER_DIR="$(${pkgs.systemd}/bin/machinectl show ${name} --value --property=RootDirectory)"
                      # ensure that the directory exists
                      ${pkgs.coreutils}/bin/mkdir -p /run/linked-container-journald/
                      # remove the symlink if it exists
                      ${pkgs.coreutils}/bin/unlink /run/linked-container-journald/${name} || true
                      # symlink the journald directory to a known location
                      ${pkgs.coreutils}/bin/ln -s "$CONTAINER_DIR/var/log/journal" /run/linked-container-journald/${name}
                    '';
                  in "${link-journald}/bin/link-journald";
                  ExecStop = "${pkgs.coreutils}/bin/unlink /run/linked-container-journald/${name}";
                };
              };
            }
        ) {}
        config.containers;
    };
}
