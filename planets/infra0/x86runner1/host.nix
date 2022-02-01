{ pkgs, ... }: {
  networking.hostName = "x86runner1";

  imports = [
    ./hardware.nix
    ../common/profiles/base.nix
  ];

  # important config
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # --- open ports ---
  networking.firewall.allowedUDPPorts = [
    25565 # minecraft
  ];
  networking.firewall.allowedTCPPorts = [
    25565 # minecraft
    8083 # calibre-web
    8448 # matrix
    443 # caddy | matrix
    80 # caddy
  ];
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [
      25565 # minecraft
    ];
    allowedTCPPorts = [
      25565 # minecraft
      8083 # calibre-web
      8448 # matrix
      443 # caddy | matrix
      80 # caddy
    ];
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # --- wireguard vpn setup ---
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.11.235.12/24" "fdbe:ef11:2358:1321::12/64" ];
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

  # --- calibre-web ---
  environment.noXlibs = false;
  services.calibre-web = {
    enable = true;
    listen.ip = "0.0.0.0";
    openFirewall = true;
    options.calibreLibrary = "/opt/stuff/books";
    options.enableBookConversion = true;

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

    after = [ "network.target" "wozey-compute.service" ];
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services."wozey-compute" = {
    description = "wozey.service compute daemon";

    serviceConfig = {
      ExecStart = "${pkgs.wozey.wozey-compute}/bin/wozey-compute";
      WorkingDirectory = "/var/lib/wozey";
      Restart = "always";
      RestartSec = "5s";
      User = "root";
      Group = "root";
    };

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" "wozey.service" ];
  };

  virtualisation.docker = {
    enable = true;
  };

  # --- matrix stuff ---
  services.matrix-conduit = {
    enable = true;
    package = pkgs.ss.matrix-conduit;
    settings = {
      global = {
        server_name = "wozenest.duckdns.org";

        database_backend = "sqlite";
        allow_registration = false;
      };
    };
  };
  services.matrix-appservice-discord = {
    enable = true;
    serviceDependencies = [ "conduit.service" ];
    environmentFile = "/keys/matrix_as_discord_env";
    settings = {
      bridge = {
        domain = "wozenest.duckdns.org";
        homeserverUrl = "https://wozenest.duckdns.org";
        adminMxid = "@wozeparrot:wozenest.duckdns.org";
      };
      auth = {
        usePrivilegedIntents = true;
      };
      room = {
        defaultVisibility = "private";
      };
    };
  };

  # --- caddy ---
  services.caddy = {
    enable = true;
    logFormat = "level ERROR";
    virtualHosts = {
      "wozenest.duckdns.org" = {
        extraConfig = ''
          reverse_proxy /_matrix/* http://localhost:6167
        '';
      };

      "wozenest.duckdns.org:8448" = {
        extraConfig = ''
          reverse_proxy http://localhost:6167
        '';
      };
    };
  };

  system.stateVersion = "21.11";
}
