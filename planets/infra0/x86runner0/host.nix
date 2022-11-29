{pkgs, ...}: {
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
  environment.systemPackages = with pkgs; [];

  # --- wireguard vpn setup ---
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.11.235.11/24" "fdbe:ef11:2358:1321::11/64"];
      dns = ["10.11.235.1" "fdbe:ef11:2358:1321::1"];

      privateKeyFile = "/keys/wg_private";

      peers = [
        {
          publicKey = "W0yvMPgWIS/qKWKPg2x+7xkHNlmvJ1Ze4iFhTS1BkXk=";
          allowedIPs = ["10.11.235.0/24" "fdbe:ef11:2358:1321::/64"];
          endpoint = "192.168.2.31:5553";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # --- containers ---
  containers.seaweedfs-node = {
    autoStart = true;
    bindMounts."/var/lib/seaweedfs/data" = {
      hostPath = "/opt/deepspace";
      isReadOnly = false;
    };
    config = {config, ...}: {
      # -- seaweedfs volume --
      systemd.services."seaweedfs-volume" = {
        description = "seaweedfs volume server";

        serviceConfig = {
          ExecStart = "${pkgs.wozepkgs.seaweedfs}/bin/weed volume -ip 10.11.235.11 -port 9311 -mserver '10.11.235.1:9301' -index leveldb -max 12 -dir /var/lib/seaweedfs/data/";
          Restart = "always";
          RestartSec = "10s";
        };

        after = ["network.target"];
        wantedBy = ["multi-user.target"];
      };

      system.stateVersion = "22.11";
    };
  };

  system.stateVersion = "21.11";
}
