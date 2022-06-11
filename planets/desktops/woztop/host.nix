{ config, pkgs, ... }:
{
  networking.hostName = "woztop";

  imports = [
    ../common/profiles/graphical.nix
    ../common/profiles/laptop.nix
    ./hardware.nix

    # ../common/profiles/desktops/hikari
    # ../common/profiles/desktops/river
    ../common/profiles/desktops/hyprland

    ../common/profiles/wireguard.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  boot.kernelParams = [ "intel_iommu=on" ];

  hardware.cpu.intel.updateMicrocode = true;

  # nix cross build support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux arm-linux i686-linux
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = {
    extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      intel-compute-runtime
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

    corectrl

    piper

    cifs-utils

    lxqt.lxqt-policykit
  ];

  programs.nm-applet.enable = true;
  programs.droidcam.enable = true;
  programs.wireshark.enable = true;
  programs.gamemode.enable = true;

  # services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
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
      qemu.ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull ];
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
    kvmgt = {
      enable = true;
      vgpus = {
        "i915-GVTg_V5_4" = {
          uuid = [ "eb1ec6dc-133e-11eb-a7a0-9714878a69bc" ];
        };
      };
    };

    #virtualbox.host = {
    #  enable = true;
    #  enableExtensionPack = true;
    #};

    docker.enable = true;
    anbox.enable = false;
  };

  fileSystems."/mnt/ss/infra0/nas0" = {
    device = "10.11.235.1:/";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  users.users.woze.extraGroups = [ "docker" "libvirtd" "video" "render" "vboxusers" "libvirt" ];
  home-manager.users.woze = ./home.nix;

  system.stateVersion = "21.11";
}
