{pkgs, ...}: {
  networking.hostName = "x86runner1";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
  ];

  # important config
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking = {
    useDHCP = false;
    interfaces.eno1 = {
      useDHCP = true;
      wakeOnLan.enable = true;
    };
  };

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
      25565 # minecraft
    ];
    allowedTCPPorts = [
      25565 # minecraft
      8083 # calibre-web
    ];
    interfaces.wg0 = {
      allowedUDPPorts = [
        25565 # minecraft
      ];
      allowedTCPPorts = [
        25565 # minecraft
        8083 # calibre-web
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # --- wireguard vpn setup ---
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.11.235.12/24" "fdbe:ef11:2358:1321::12/64"];
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

  # --- calibre-web ---
  environment.noXlibs = false;
  services.calibre-web = {
    enable = true;
    listen.ip = "0.0.0.0";
    openFirewall = true;
    options = {
      calibreLibrary = "/opt/stuff/books";
      enableBookConversion = true;
      enableBookUploading = true;
    };

    user = "root";
    group = "root";
  };

  # --- wozey.service ---
  systemd.services."wozey" = {
    description = "wozey.service daemon";

    serviceConfig = {
      ExecStart = "${pkgs.wozey.wozey}/bin/wozey";
      WorkingDirectory = "/var/lib/wozey";
      Restart = "always";
      RestartSec = "5s";
    };

    after = ["network.target" "wozey-compute.service"];
    wantedBy = ["multi-user.target"];
  };
  systemd.services."wozey-compute" = {
    enable = true;
    description = "wozey.service compute daemon";

    serviceConfig = {
      ExecStart = "${pkgs.wozey.wozey-compute}/bin/wozey-compute";
      WorkingDirectory = "/var/lib/wozey";
      Restart = "always";
      RestartSec = "5s";
      User = "root";
      Group = "root";
    };

    after = ["network.target"];
    wantedBy = ["multi-user.target" "wozey.service"];
  };

  virtualisation.docker = {
    enable = true;
  };

  system.stateVersion = "21.11";
}
