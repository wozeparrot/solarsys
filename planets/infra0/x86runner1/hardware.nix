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

  boot = {
    initrd = {
      availableKernelModules = ["ata-generic" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod"];
      kernelModules = [];
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e565d021-0e7b-492c-ae95-60932730a9f2";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D6FE-6783";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/ed622d7a-b584-4543-9edb-c04f311d4cc7";
    }
  ];
}
