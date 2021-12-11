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
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowedTCPPorts = [ ];

  # --- packages ---
  environment.systemPackages = with pkgs; [
    docker-compose

    mpv
    aninarr.aninarc

    pamix
    pamixer
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

  # --- htpc ---
  hardware.opengl.enable = true;
  services.dbus.enable = true;

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    support32Bit = true;
  };

  environment.noXlibs = false;
  users.groups.pulse-access = {};
  users.users.user = {
    initialPassword = "toor";
    isNormalUser = true;
    extraGroups = [ "audio" "video" "pulse" "pulse-access" ];
  };
  system.activationScripts.fix-pulse-permissions = ''
    chmod 755 /run/pulse
  '';

  services.cage = {
    enable = true;
    user = "user";
    program = "${pkgs.aninarr.aninarc}/bin/aninarc";
  };

  systemd.services."cage-tty1" = {
    serviceConfig.Restart = "always";
    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";
      NO_AT_BRIDGE = "1";
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  system.stateVersion = "21.11";
}
