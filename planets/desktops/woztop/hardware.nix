{
  config,
  stdenv,
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel" "vfio-pci"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6e134c4b-cf6f-462b-bf1d-61f7acfcbf93";
    fsType = "xfs";
  };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/dcaf7525-88c3-4049-b13a-578a1cf8a21c";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9151-7D77";
    fsType = "vfat";
  };

  fileSystems."/mnt/vms" = {
    device = "/dev/disk/by-uuid/e37e9b42-3c8f-49ad-be6e-44cc5bd20f61";
    fsType = "xfs";
  };

  swapDevices = [];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
