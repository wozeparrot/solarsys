{ pkgs, config, ... }: {
  networking.hostName = "nas1";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  # --- mount disks --- 
  fileSystems = {
    "/mnt/storage" = {
      device = "/dev/disk/by-uuid/b26f275b-b03d-4895-89e2-c986cab78a00";
      fsType = "xfs";
    };
  };
  boot.supportedFilesystems = [ "ntfs" "btrfs" ];

  # --- open ports ---
  networking.firewall.allowedUDPPorts = [
  ];
  networking.firewall.allowedTCPPorts = [
    # samba
    139
    445

    # motioneye
    8765
    8081
    8082

    # home-assistant
    8123
    1883
    9001

    # nextcloud
    8080
  ];

  # --- packages ---
  environment.systemPackages = with pkgs; [ ];

  # --- services ---
  # docker
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    containers = {
      samba = {
        image = "dperson/samba";
        ports = [ "139:139" "445:445" ];
        volumes = [ "/mnt/storage/public:/share" ];
        cmd = [ "-p" "-spublic;/share;yes;no" ];
      };
      motioneye = {
        image = "ccrisan/motioneye:master-armhf";
        ports = [ "8765:8765" "8081:8081" "8082:8082" ];
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
          "/mnt/storage/docker/motioneye/config:/etc/motioneye"
          "/mnt/storage/docker/motioneye/recording:/var/lib/motioneye"
        ];
      };
      homea = {
        image = "homeassistant/raspberrypi4-homeassistant:stable";
        extraOptions = [ "--net=host" ];
        environment.TZ = config.time.timeZone;
        volumes = [
          "/mnt/storage/docker/homea/config:/config"
          "/mnt/storage/public/Pictures:/media:ro"
        ];
      };
      mosquitto = {
        image = "eclipse-mosquitto";
        volumes = [
          "/mnt/storage/docker/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf"
          "/mnt/storage/docker/mosquitto/data:/mosquitto/data"
          "/mnt/storage/docker/mosquitto/log:/mosquitto/log"
        ];
        ports = [ "1883:1883" "9001:9001" ];
      };
      nc-db = {
        image = "mariadb:latest";
        environment = {
          MYSQL_ROOT_PASSWORD = "Hyd+1382968";
          MYSQL_DATABASE = "nextcloud";
          MYSQL_USER = "user";
          MYSQL_PASSWORD = "nc1382968";
        };
        volumes = [ "/mnt/storage/docker/nc-db:/var/lib/mysql" ];
        cmd = [
          "--character-set-server=utf8mb4"
          "--collation-server=utf8mb4_unicode_ci"
        ];
      };
      nextcloud = {
        image = "nextcloud:latest";
        ports = [ "8080:80" ];
        extraOptions = [ "--link=nc-db:db" ];
        volumes = [
          "/mnt/storage/public/Pictures:/photos"
          "/mnt/storage/docker/nextcloud:/var/www/html"
        ];
        dependsOn = [ "nc-db" ];
      };
    };
  };

  # cron
  services.cron.enable = true;

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  system.stateVersion = "21.11";
}
