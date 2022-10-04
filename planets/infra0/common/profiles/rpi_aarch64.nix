{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./base.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.loader.raspberryPi.enable = true;
  boot.loader.grub.enable = false;
  # boot.loader.generic-extlinux-compatible.enable = true;

  sdImage.compressImage = false;
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
      options = ["relatime"];
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.master) bind;
      inherit (prev.master) ripgrep;
      inherit (prev.master) neovim;
      pango = prev.pango.overrideAttrs (oldAttrs: {
        outputs = ["bin" "out" "dev"];
        mesonFlags = ["-Dintrospection=disabled" "-Dgtk_doc=false"];
        postInstall = "";
      });
    })
  ];
}
