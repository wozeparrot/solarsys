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
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  sdImage = {
    compressImage = false;
    firmwareSize = 128;
    firmwarePartitionName = "NIXOS_BOOT";
    populateRootCommands =
      let
        populateCmd = config.boot.loader.generic-extlinux-compatible.populateCmd;
      in
      ''
        mkdir -p ./files/boot
        ${populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
      '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "relatime" ];
    };
  };
}
