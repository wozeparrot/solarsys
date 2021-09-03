{ pkgs, config, inputs, ... }: {
  imports = [
    ./base.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "cma=32M" ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  sdImage.firmwareSize = 128;
  sdImage.firmwarePartitionName = "NIXOS_BOOT";
  sdImage.populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  '';

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      ripgrep = prev.ripgrep.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];
}
