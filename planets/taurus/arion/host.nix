{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "arion";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
      5553 # wireguard
      5554 # wgautomesh
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

  # --- wireguard setup ---
  networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = (lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) {hostname = null;} (import ../../../networks/orion.nix)).hostname == config.networking.hostName;
  networking.wireguard.interfaces.orion = {
    ips = ["${(lib.lists.findFirst (x: x.hostname == config.networking.hostName) (builtins.abort "failed to find node in network") (import ../../../networks/orion.nix)).address}/24"];
    listenPort = 5553;

    privateKeyFile = "/keys/wg_private";

    peers =
      lib.lists.optionals ((lib.lists.findFirst (x: lib.strings.hasPrefix "hub" x.type) {hostname = null;} (import ../../../networks/orion.nix)).hostname == config.networking.hostName)
      (map (x: {
          publicKey = x.pubkey;
          endpoint = x.endpoint;
          allowedIPs = ["${x.address}/32"];
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && (lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) [] (import ../../../networks/orion.nix)));
  };
  services.wgautomesh = {
    enable = true;
    settings = {
      interface = "orion";
      gossip_port = 5554;
      peers =
        map (x: {
          inherit (x) address pubkey endpoint;
        }) (lib.lists.foldl (acc: cur:
          if cur.hostname != config.networking.hostName && !(lib.strings.hasInfix "client" cur.type)
          then acc ++ [cur]
          else acc) [] (import ../../../networks/orion.nix));
    };
    gossipSecretFile = "/keys/wgam_gossip_secret";
  };

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
