{ pkgs, ... }:
let
  ubootRaspberryPi5 =
    (pkgs.buildUBoot rec {
      version = "2024.04-rc2";

      src = pkgs.fetchurl {
        url = "https://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
        hash = "sha256-Pns5SJm1Wp12nyihm1QlNg7y20ZaU2F701SwH7YZkrI=";
      };

      defconfig = "rpi_arm64_defconfig";
      extraMakeFlags = [ "DTC=${pkgs.dtc}/bin/dtc" ];
      extraMeta.platforms = [ "aarch64-linux" ];
      filesToInstall = [ "u-boot.bin" ];
    }).overrideAttrs
      (old: {
        patches = [ ];

        strictDeps = true;
        nativeBuildInputs =
          old.nativeBuildInputs
          ++ (with pkgs; [
            libuuid
            gnutls
          ]);
        buildInputs = [ ];
      });
in
{
  imports = [ ./rpi_base.nix ];

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  sdImage.populateFirmwareCommands =
    let
      configTxt = pkgs.writeText "config.txt" ''
        kernel=u-boot.bin

        # set stuff
        arm_boost=1
        disable_overscan=1

        # boot in 64bit mode
        arm_64bit=1
        enable_gic=1
        armstub=armstub8-gic.bin

        # prevent framebuffer smashing
        avoid_warnings=1

        # needed for uboot
        enable_uart=1
      '';
    in
    ''
      (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

      cp ${ubootRaspberryPi5}/u-boot.bin firmware/u-boot.bin
      cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2712-rpi-5-b.dtb firmware/

      cp ${configTxt} firmware/config.txt
    '';
}
