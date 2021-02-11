# must be used with:
# base, graphical

{ config, pkgs, mpkgs, lib, ... }: {
  imports = [ ./base.nix ./graphical.nix ./network.nix ];

  # system packages
  environment.systemPackages = with pkgs; [
    acpi
    lm_sensors
    wirelesstools
  ];

  # enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # backlight control
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 5";
      }
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 5";
      }
    ];
  };

  # power management
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;

    CPU_MIN_PERF_ON_AC = 0;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MAX_PERF_ON_BAT = 30;
  };
  services.logind.lidSwitch = "suspend";
}
