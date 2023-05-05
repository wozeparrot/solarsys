{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./rpi_aarch64.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  boot.loader.raspberryPi.version = 4;
  boot.loader.raspberryPi.firmwareConfig = ''
    arm_boost=1
  '';

  sdImage.populateFirmwareCommands = let
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
  in ''
    (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

    cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot.bin
    cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/

    cp ${configTxt} firmware/config.txt
  '';
}
