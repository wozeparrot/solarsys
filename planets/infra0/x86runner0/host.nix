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
    25565
  ];
  networking.firewall.allowedTCPPorts = [
    25565
  ];

  # --- packages ---
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

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
        }
      ];
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  system.stateVersion = "21.11";
}
