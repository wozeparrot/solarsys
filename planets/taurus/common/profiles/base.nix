{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ../../../../common/profiles/base.nix
  ];

  # disabled unneeded stuff
  environment.noXlibs = lib.mkDefault true;
  security = {
    polkit.enable = lib.mkDefault false;
    audit.enable = false;
  };
  services.udisks2.enable = false;

  # remove docs
  documentation = {
    enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # remove unneeded locales
  i18n.supportedLocales = [(config.i18n.defaultLocale + "/UTF-8")];

  # remove fonts
  fonts.fontconfig.enable = lib.mkDefault false;

  # remove sound
  sound.enable = lib.mkDefault false;

  # enable ssh
  services.openssh.enable = lib.mkForce true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot"
  ];

  # reboot on kernel panic
  boot.kernelParams = ["panic=1" "boot.panic_on_fail"];

  # systemd tweaks
  systemd.enableEmergencyMode = false;
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  # firewall
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [22];
    };
  };

  # use tcp bbr
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # cleanup
  nix.settings.auto-optimise-store = true;
}
