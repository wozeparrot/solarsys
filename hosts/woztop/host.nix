{ config, pkgs, master, ... }:
{
  networking.hostName = "woztop";

  imports = [
    ../../common/profiles/graphical.nix
    ../../common/profiles/laptop.nix
    ./hardware.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_lqx;
  boot.kernelParams = [ "intel_iommu=on" ];
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = {
    extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel amdvlk ];
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      intel-compute-runtime
      amdvlk
    ];
  };

  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 29999 ];
  networking.firewall.allowedUDPPorts = [ 29999 ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer

    corectrl
  ];

  programs.nm-applet.enable = true;

  # services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" "modesetting" ];
  services.xserver.displayManager = {
    autoLogin = {
      enable = true;
      user = "woze";
    };
    lightdm.enable = true;
    session = [
      {
        manage = "window";
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }
    ];
    defaultSession = "xfce+home-manager";
  };
  services.xserver.desktopManager = {
    xterm.enable = false;
    xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
      thunarPlugins = [ pkgs.xfce.thunar-archive-plugin ];
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuOvmf = true;
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

    docker.enable = true;
  };

  users.users.woze.extraGroups = [ "docker" "libvirtd" "video" "render" ];
  home-manager.users.woze = ./home.nix;
}
