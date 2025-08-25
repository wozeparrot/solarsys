{
  lib,
  config,
  pkgs,
  ...
}:
let
  orion = import ../../../../networks/orion.nix;
  cfg = config.containered-services.nats;
in
{
  options.containered-services.nats = {
    enable = lib.mkEnableOption "nats server";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      4222
    ];
    networking.firewall.allowedUDPPorts = [
    ];

    containers.nats = {
      autoStart = true;
      ephemeral = true;

      config =
        { cconfig, ... }:
        {
          services.nats = {
            enable = true;
            serverName = config.networking.hostName;
          };

          system.stateVersion = config.system.stateVersion;
        };
    };
  };
}
