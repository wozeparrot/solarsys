{pkgs, ...}: {
  imports = [
    ./rpi_base.nix
  ];

  sdImage.populateFirmwareCommands = let
    configTxt = pkgs.writeText "config.txt" ''
      kernel=u-boot.bin

      # boot in 64bit mode
      arm_64bit=1

      # prevent framebuffer smashing
      avoid_warnings=1

      # needed for uboot
      enable_uart=1
    '';
  in ''
    (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

    cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot.bin

    cp ${configTxt} firmware/config.txt
  '';
}
