{ pkgs, config, lib, ... }: {
  imports = [
    ../../../../common/profiles/base.nix
  ];

  # disabled unneeded stuff
  environment.noXlibs = lib.mkDefault true;
  security.polkit.enable = lib.mkDefault false;
  security.audit.enable = false;
  services.udisks2.enable = false;

  # remove docs
  documentation.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # Remove unneeded locales
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  # enable ssh
  services.openssh.enable = lib.mkForce true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot"
  ];

  # Reboot on kernel panic
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # no systemd emergency mode
  systemd.enableEmergencyMode = false;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # cleanup
  nix.settings.auto-optimise-store = true;
  boot.cleanTmpDir = true;
}
