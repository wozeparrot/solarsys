{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      grub.enable = false;
    };

    initrd.kernelModules = [
      "rockchip_rga"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"

      "analogix_dp"
      "cec"
      "drm"
      "drm_kms_helper"
      "dw_hdmi"
      "dw_mipi_dsi"
      "gpu_sched"
      "panel_edp"
      "panel_simple"
      "panfrost"
      "pwm_bl"

      "fusb302"
      "tcpm"
      "typec"

      "cw2015_battery"
      "gpio_charger"
      "rtc_rk808"
    ];

    kernelParams = [
      "rootwait"

      "earlycon"
      "consoleblank=0"
      "console=ttyS2,1500000"
      "console=tty1"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };
}
