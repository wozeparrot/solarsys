{ config, pkgs, ... }:
{
  networking.hostName = "woztop-horizon";

  imports = [
    ../common/profiles/graphical.nix
    ../common/profiles/laptop.nix
    ./hardware.nix

    # ../common/profiles/desktops/hikari
    ../common/profiles/desktops/river
    # ../common/profiles/desktops/hyprland

    ../common/profiles/vpn.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  hardware.cpu.amd.updateMicrocode = true;

  # nix cross build support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux arm-linux i686-linux
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = {
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    driSupport = true;
    driSupport32Bit = true;
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

    lxqt.lxqt-policykit
  ];

  programs.nm-applet.enable = true;
  programs.droidcam.enable = true;
  programs.wireshark.enable = true;
  programs.gamemode.enable = true;
  programs.fuse.userAllowOther = true;
  programs.corectrl.enable = true;

  # services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin pkgs.hplip ];

  services.gvfs.enable = true;

  services.ratbagd.enable = true;

  services.tlp.settings.WIFI_PWR_ON_BAT = "off";

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
    { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
  ];

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

    docker.enable = true;
    anbox.enable = false;
  };

  fileSystems."/mnt/ss/infra0/nas0" = {
    device = "10.11.235.1:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  users.users.woze.extraGroups = [ "docker" "libvirtd" "video" "render" "vboxusers" "libvirt" "corectrl" ];
  home-manager.users.woze = ./home.nix;

  system.stateVersion = "22.11";
}
