{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "arion";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
  ];

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
    ];
    allowedTCPPorts = [
      80
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

  # --- nextcloud ---
  containers.nextcloud = {
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
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/nextcloud";
          ExecStart = "${pkgs.seaweedfs}/bin/weed mount -dir /var/lib/nextcloud -filer.path /services/nextcloud -filer=10.11.235.1:9302 -concurrentWriters 128";
          ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
          Restart = "on-failure";
          RestartSec = "10s";
        };

        after = ["network.target"];
        before = ["nextcloud-setup.service"];
        wantedBy = ["multi-user.target"];
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud26;
        hostName = "10.11.235.21";

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
        config = {
          extraTrustedDomains = ["192.168.0.194"];

          adminuser = "root";
          adminpassFile = "/keys/nextcloud_adminpass";

          dbtype = "sqlite";

          defaultPhoneRegion = "CA";
        };
        extraOptions = {
          preview_max_x = 1024;
          preview_max_y = 1024;
        };
      };

      system.stateVersion = config.system.stateVersion;
    };
  };

  system.stateVersion = "23.05";
}
