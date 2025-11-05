{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-amd"
      "cpufreq_powersave"
      "i2c-dev"
      "v4l2loopback"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      # rtl8852bu
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=3 video_nr=11,12,13 exclusive_caps=1,1,1 card_label=X_11,X_12,X_13
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/75c63322-d44c-4cbf-9c7e-86c1e628cc6f";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
      ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/75c63322-d44c-4cbf-9c7e-86c1e628cc6f";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd"
      ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/75c63322-d44c-4cbf-9c7e-86c1e628cc6f";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/521B-EC33";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
}
