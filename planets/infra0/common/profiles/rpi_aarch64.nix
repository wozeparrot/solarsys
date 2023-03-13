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

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      # generic-extlinux-compatible.enable = true;
      raspberryPi.enable = true;
      grub.enable = false;
    };
  };

  sdImage = {
    compressImage = false;
    firmwareSize = 128;
    firmwarePartitionName = "NIXOS_BOOT";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

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
