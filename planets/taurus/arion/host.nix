{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "arion";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
    ../common/containered-services/nextcloud.nix
    ../common/components/common-metrics.nix
  ];

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
    ];
    allowedTCPPorts = [
      8765
    ];
    interfaces.orion = {
      allowedUDPPorts = [
      ];
      allowedTCPPorts = [
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [];

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  # --- metrics ---
  components.common-metrics.enable = true;

  # --- nextcloud ---
  containered-services.nextcloud.enable = true;

  # --- motioneye ---
  containers.motioneye = {
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
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/motioneye";
          ExecStart = "${pkgs.seaweedfs}/bin/weed mount -dir /var/lib/motioneye -filer.path /services/motioneye -filer=10.11.235.1:9302";
          ExecStartPost = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.util-linux}/bin/mountpoint -q /var/lib/motioneye; do sleep 1; done'";
          Restart = "on-failure";
          RestartSec = "10s";
        };

        after = ["network.target"];
        before = ["motioneye.service"];
        wantedBy = ["multi-user.target"];
      };

      systemd.services.motioneye = {
        description = "motioneye";

        serviceConfig = let
          configFile = pkgs.writeText "motioneye.conf" ''
            conf_path /var/lib/motioneye/conf
            run_path /run/motioneye
            log_path /var/log/motioneye
            media_path /var/lib/motioneye/media

            log_level info

            listen 0.0.0.0
            port 8765

            motion_binary ${pkgs.motion}/bin/motion
            motion_control_localhost true
            motion_control_port 7999
            motion_check_interval 10
            motion_restart_on_errors false

            mount_check_interval 300
            cleanup_interval 43200

            remote_request_timeout 10
            mjpg_client_timeout 10
            mjpg_client_idle_timeout 10

            smb_shares false
            smb_mount_root /media

            smtp_timeout 60
            list_media_timeout 120
            list_media_timeout_email 10
            list_media_timeout_telegram 10
            zip_timeout 500
            timelapse_timeout 500

            enable_reboot false
            add_remove_cameras true

            http_basic_auth false
          '';
        in {
          ExecStart = "${pkgs.ss.motioneye}/bin/meyectl startserver -c ${configFile}";
          Restart = "on-failure";
          RestartSec = "30s";

          User = "motioneye";
          Group = "motioneye";

          LogsDirectory = "motioneye";
          RuntimeDirectory = "motioneye";
        };

        wantedBy = ["multi-user.target"];
      };

      users = {
        users.motioneye = {
          home = "/var/lib/motioneye";
          isSystemUser = true;
          group = "motioneye";
        };

        groups.motioneye = {};
      };

      system.stateVersion = config.system.stateVersion;
    };
  };

  system.stateVersion = "23.05";
}
