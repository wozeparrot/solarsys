{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "woztop-horizon";

  imports = [
    ../common/profiles/graphical.nix
    ../common/profiles/laptop.nix
    ./hardware.nix

    # ../common/profiles/desktops/hikari
    # ../common/profiles/desktops/river
    ../common/profiles/desktops/hyprland

    ../common/profiles/vpn.nix
  ];

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  boot.kernelPackages = pkgs.chaotic.linuxPackages_cachyos-lto;
  boot.kernelPatches = [ ];
  boot.kernelParams = [
    "amd_pstate=active"
    "psi=1"
  ];

  specialisation = {
    cwsr-disabled.configuration = {
      boot.kernelParams = [ "amdgpu.cwsr_enable=0" ];
    };

    amdgpu-od.configuration = {
      boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
    };
  };

  hardware.cpu.amd.updateMicrocode = true;

  # nix cross build support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux i686-linux
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };
  hardware.uinput.enable = true;
  hardware.opentabletdriver.enable = true;

  networking.firewall.allowedTCPPorts = [ 29999 ];
  networking.firewall.allowedUDPPorts = [ 29999 ];

  networking.firewall.interfaces.wg-ss = {
    allowedUDPPorts = [ 6504 ];
    allowedTCPPorts = [ 6504 ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer

    piper

    cifs-utils

    gpu-screen-recorder

    scx.full

    ss.xencelabs

    ddcutil
    inotify-tools
  ];

  programs.nm-applet.enable = true;
  programs.droidcam.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  programs.gamemode.enable = true;
  programs.fuse.userAllowOther = true;
  programs.corectrl.enable = true;
  programs.adb.enable = true;
  programs.steam.enable = true;

  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 woze kvm -" ];

  # services.flatpak.enable = true;

  services.xserver.videoDrivers = [
    "amdgpu"
    "modesetting"
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"
    ATTRS{idVendor}=="373b", MODE="0666", GROUP="users"

    # Read write access for all USB3Vision devices
    SUBSYSTEM=="usb", ATTRS{bDeviceClass}=="ef", ATTRS{bDeviceSubClass}=="02", ATTRS{bDeviceProtocol}=="01", ENV{ID_USB_INTERFACES}=="*:ef0500:*", MODE="0666"

    # i2c devices
    SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
  '';
  services.udev.packages = with pkgs; [
    openocd
    platformio-core
    ss.xencelabs
  ];

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    hplip
    foo2zjs
  ];

  services.gvfs.enable = true;

  services.ratbagd.enable = true;

  services.asusd = {
    enable = true;
    asusdConfig = {
      text = ''
        (
          bat_charge_limit: 60,
          panel_od: false,
        )
      '';
    };
  };
  services.supergfxd.enable = false;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];
  security.wrappers."gsr-kms-server" = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
        swtpm.enable = true;
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    docker = {
      enable = true;
      enableOnBoot = false;
    };

    # waydroid.enable = true;
    # lxd.enable = true;
  };

  # fileSystems."/mnt/ss/infra0/nas0" = {
  #   device = "10.11.235.1:/";
  #   fsType = "nfs";
  #   options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
  # };

  # add i2c group
  users.groups.i2c = {};
  users.users.woze.extraGroups = [
    "docker"
    "libvirtd"
    "video"
    "render"
    "vboxusers"
    "libvirt"
    "corectrl"
    "adbusers"
    "wireshark"
    "kvm"
    "i2c"
  ];
  home-manager.users.woze = ./home.nix;

  system.stateVersion = "22.11";
}
