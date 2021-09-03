{ pkgs, config, lib, ... }: {
  imports = [
    ../../../../common/profiles/base.nix
  ];

  # disabled unneeded stuff
  environment.noXlibs = true;
  security.polkit.enable = false;
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
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    
  ];

  # Reboot on kernel panic
  boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # store
  nix.autoOptimiseStore = true;
}
