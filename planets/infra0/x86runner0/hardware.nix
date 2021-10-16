{ config, stdenv, pkgs, modulesPath, lib, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_atiixp" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/bddaadbf-7920-4e7b-ae36-4a8ce45aff30";
      fsType = "xfs";
    };

  swapDevices = [
    {
      label = "swap";
    }
  ];
}
