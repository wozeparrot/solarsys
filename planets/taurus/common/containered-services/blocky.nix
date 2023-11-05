{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.blocky;
in {
  options.containered-services.blocky = {
    enable = mkEnableOption "blocky dns proxy/adblocker";
    bindAddress = mkOption {
      type = types.str;
      default = (lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") orion).address;
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

      config = {cconfig, ...}: {
        services.blocky = {
          enable = true;
          settings = {
            ports = {
              dns = "0.0.0.0:53";
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
                  "https://dns.google/dns-query"
                ];
              };
            };
            blocking = {
              blackLists = {
                ads = [
                  "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                  "https://adaway.org/hosts.txt"
                  "https://raw.githubusercontent.com/logroid/adaway-hosts/master/hosts.txt"
                  "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
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
              type = "console";
            };
          };
        };
        systemd.services."blocky".serviceConfig.DynamicUser = lib.mkForce false;

        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
