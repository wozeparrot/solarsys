# must be used with:
# base, graphical
{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  # power management
  boot.kernelParams = [ "rcutree.enable_rcu_lazy=1" ];
  services = {
    tlp = {
      enable = lib.mkDefault true;
      settings = {
        CPU_DRIVER_OPMODE_ON_AC = "active";
        CPU_DRIVER_OPMODE_ON_BAT = "active";

        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_SCALING_MIN_FREQ_ON_AC = "400000";
        CPU_SCALING_MAX_FREQ_ON_AC = "4935000";
        CPU_SCALING_MIN_FREQ_ON_BAT = "400000";
        CPU_SCALING_MAX_FREQ_ON_BAT = "3000000";

        CPU_MIN_PERF_ON_AC = "0";
        CPU_MAX_PERF_ON_AC = "100";
        CPU_MIN_PERF_ON_BAT = "0";
        CPU_MAX_PERF_ON_BAT = "70";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_BOOST_ON_AC = "1";
        CPU_BOOST_ON_BAT = "0";

        NMI_WATCHDOG = "0";

        RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
        RADEON_DPM_STATE_ON_AC = "performance";
        RADEON_DPM_STATE_ON_BAT = "battery";

        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        WOL_DISABLE = "Y";

        START_CHARGE_THRESH_BAT0 = "0";
        STOP_CHARGE_THRESH_BAT0 = "60";

        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "quiet";
      };
    };
  };

  # lid switch
  services.logind.lidSwitch = "suspend";
}
