# must be used with:
# base, graphical

{ config, pkgs, ... }: {
  imports = [ ./graphical.nix ];

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
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";

    CPU_SCALING_MIN_FREQ_ON_AC = "400000";
    CPU_SCALING_MAX_FREQ_ON_AC = "4935000";
    CPU_SCALING_MIN_FREQ_ON_BAT = "400000";
    CPU_SCALING_MAX_FREQ_ON_BAT = "2400000";

    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "0";

    SCHED_POWERSAVE_ON_AC = "0";
    SCHED_POWERSAVE_ON_BAT = "1";

    NMI_WATCHDOG = "0";

    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";

    RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
    RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
    RADEON_DPM_STATE_ON_AC = "performance";
    RADEON_DPM_STATE_ON_BAT = "battery";

    WOL_DISABLE = "Y";

    START_CHARGE_THRESH_BAT0 = "0";
    STOP_CHARGE_THRESH_BAT0 = "80";

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "quiet";
  };
  services.logind.lidSwitch = "suspend";
}
