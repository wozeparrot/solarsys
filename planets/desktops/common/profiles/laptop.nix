# must be used with:
# base, graphical
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./graphical.nix
    ./efi.nix
  ];

  # system packages
  environment.systemPackages = with pkgs; [
    acpi
    lm_sensors
    wirelesstools
  ];

  # enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # backlight control
  programs.light.enable = true;

  # power management
  boot.kernelParams = [ "rcutree.enable_rcu_lazy=1" ];
  services.tuned = {
    enable = lib.mkDefault true;
    settings = {
      dynamic_tuning = true;
    };
  };

  # lid switch
  services.logind.settings.Login.HandleLidSwitch = lib.mkDefault "suspend";
}
