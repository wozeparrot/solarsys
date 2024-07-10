{ pkgs, ... }:
{
  containers.caddy = {
    autoStart = false;
    ephemeral = true;

    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];

    additionalCapabilities = [ "CAP_MKNOD" ];

    extraFlags = [ "--bind=/dev/fuse" ];

    config =
      { config, ... }:
      {
        # mount seaweedfs
        systemd.services."seaweedfs-mount" = {
          description = "mount seaweedfs for/in container";

          path = with pkgs; [ fuse3 ];

          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/caddy";
            ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed mount -dir /var/lib/caddy -filer.path /services/caddy -filer=10.11.235.1:9302";
            ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = [ "network.target" ];
          before = [ "caddy.target" ];
          wantedBy = [
            "multi-user.target"
            "caddy.target"
          ];
        };

        services.caddy = {
          enable = true;
          virtualHosts = {
            # "ak.enqy.one" = {
            #   extraConfig = ''
            #     reverse_proxy :7320
            #   '';
            # };
          };
        };
        systemd.services."caddy" = {
          after = [ "seaweedfs-mount.service" ];
        };

        system.stateVersion = "22.11";
      };
  };
}
