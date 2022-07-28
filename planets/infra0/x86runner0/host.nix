{ pkgs, ... }: {
  networking.hostName = "x86runner0";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
  ];

  # important config
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp2s0.wakeOnLan.enable = true;
  networking.interfaces.enp3s6.useDHCP = true;
  networking.interfaces.enp3s6.wakeOnLan.enable = true;

  # --- open ports ---
  networking.firewall.allowedUDPPorts = [
    # minecraft server
    25565
  ];
  networking.firewall.allowedTCPPorts = [
    # minecraft server
    25565
  ];
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [
      # minecraft server
      25565
    ];
    allowedTCPPorts = [
      # minecraft server
      25565

      # seaweedfs
      9301
      19301
      9302
      19302
      9311
      19311
    ];
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- wireguard vpn setup ---
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.11.235.11/24" "fdbe:ef11:2358:1321::11/64" ];
      dns = [ "10.11.235.1" "fdbe:ef11:2358:1321::1" ];

      privateKeyFile = "/keys/wg_private";

      peers = [
        {
          publicKey = "W0yvMPgWIS/qKWKPg2x+7xkHNlmvJ1Ze4iFhTS1BkXk=";
          allowedIPs = [ "10.11.235.0/24" "fdbe:ef11:2358:1321::/64" ];
          endpoint = "192.168.2.31:5553";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1"
    ];
  };

  # --- containers ---
  containers.seaweedfs-brain = {
    autoStart = true;
    config = { config, ... }: {
      # oneshot systemd service to create /var/lib/seaweedfs
      systemd.services."seaweedfs-preinit" = {
        description = "Preinit stuff for seaweedfs";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/mkdir -p /var/lib/seaweedfs/master/";
        };

        wantedBy = [ "multi-user.target" ];
      };

      # -- seaweedfs master --
      environment.etc."seaweedfs/master.toml".text = ''
        [master.maintenance]
        scripts = """
          lock
          ec.encode -fullPercent=95 -quietFor=1h
          ec.rebuild -force
          ec.balance -force
          volume.deleteEmpty -quietFor=24h -force
          volume.balance -force
          volume.fix.replication
          unlock
        """
        sleep_minutes = 17

        [master.sequencer]
        type = "raft"

        [master.volume_growth]
        copy_1 = 7
        copy_2 = 6
        copy_3 = 3
        copy_other = 1
      '';
      systemd.services."seaweedfs-master" = {
        description = "seaweedfs master server";

        serviceConfig = {
          ExecStart = "${pkgs.wozepkgs.seaweedfs}/bin/weed master -ip 10.11.235.11 -port 9301 -mdir '/var/lib/seaweedfs/master/'";
          Restart = "always";
          RestartSec = "10s";
        };

        after = [ "network.target" "seaweedfs-preinit.service" ];
        wantedBy = [ "multi-user.target" ];
      };

      # -- seaweedfs filer --
      environment.etc."seaweedfs/filer.toml".text = ''
        [filer.options]
        recursive_delete = false

        [leveldb2]
        enabled = false

        [leveldb3]
        enabled = true
        dir = "/var/lib/seaweedfs/filerldb3/"
      '';
      systemd.services."seaweedfs-filer" = {
        description = "seaweedfs filer server";

        serviceConfig = {
          ExecStart = "${pkgs.wozepkgs.seaweedfs}/bin/weed filer -ip 10.11.235.11 -port 9302 -master '127.0.0.1:9301'";
          Restart = "always";
          RestartSec = "10s";
        };

        after = [ "network.target" "seaweedfs-master.service" "seaweedfs-preinit.service" ];
        wantedBy = [ "multi-user.target" ];
      };

      system.stateVersion = "22.11";
    };
  };
  containers.seaweedfs-node = {
    autoStart = true;
    bindMounts."/var/lib/seaweedfs/data" = {
      hostPath = "/opt/deepspace";
      isReadOnly = false;
    };
    config = { config, ... }: {
      # -- seaweedfs volume --
      systemd.services."seaweedfs-volume" = {
        description = "seaweedfs volume server";

        serviceConfig = {
          ExecStart = "${pkgs.wozepkgs.seaweedfs}/bin/weed volume -ip 10.11.235.11 -port 9311 -mserver '127.0.0.1:9301' -index leveldb -max 12 -dir /var/lib/seaweedfs/data/";
          Restart = "always";
          RestartSec = "10s";
        };

        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
      };

      system.stateVersion = "22.11";
    };
  };

  system.stateVersion = "21.11";
}
