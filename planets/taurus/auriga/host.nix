{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "auriga";

  imports = [
    ../common/profiles/rpi4.nix
    ../common/profiles/vpn.nix
  ];

  # --- open ports ---
  networking.firewall = {
    allowedUDPPorts = [
    ];
    allowedTCPPorts = [
    ];
    interfaces.orion = {
      allowedUDPPorts = [
      ];
      allowedTCPPorts = [
      ];
    };
  };

  # --- packages ---
  environment.systemPackages = with pkgs; [];

  # udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", TEST=="power/autosuspend" ATTR{power/autosuspend}="-1"
  '';

  system.stateVersion = "23.05";
}
