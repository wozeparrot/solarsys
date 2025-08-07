{ config, pkgs, ... }:
{
  nix.settings.trusted-users = [ "woze" ];

  users.users.woze = {
    isNormalUser = true;
    hashedPassword = "$6$UViRjZMnBsCT7$U6tbj1.hFnQgxnN6pm5yaF2AiXsuVVxUGpBC3kMpDLyrUXOnocdxatx.Ffmalu8IzhhSA/i2EjpvlIOgSLLJS0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot"
    ];
    extraGroups = [
      "adbusers"
      "audio"
      "corectrl"
      "dialout"
      "input"
      "kvm"
      "libvirt"
      "libvirtd"
      "plugdev"
      "render"
      "uinput"
      "video"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.fish;
  };
}
