{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "wlab";

  imports = [
    ./hardware.nix

    ../common/profiles/laptop.nix

    ../common/profiles/desktops/hyprland
  ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  services.xserver.videoDrivers = [
    "modesetting"
  ];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    # viture pro xr (35ca:101d)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="35ca", ATTRS{idProduct}=="101d", MODE="0666"
  '';
  services.udev.packages = with pkgs; [
  ];

  networking.firewall.allowedTCPPorts = [ 29999 ];
  networking.firewall.allowedUDPPorts = [ 29999 ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # kdeconnect
  ];

  # ssh
  services.openssh.enable = true;
  services.openssh.startWhenNeeded = true;

  services.tlp.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      terminal = {
        vt = 1;
      };
      initial_session = {
        command = "hyprland-run";
        user = "woze";
      };
    };
  };

  programs.nm-applet.enable = true;

  environment.systemPackages = with pkgs; [
    waypipe
  ];

  home-manager.users.woze = ./home.nix;

  system.stateVersion = "25.11";
}
