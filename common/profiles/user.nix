{ config, pkgs, mpkgs, ... }:
{
  nix.trustedUsers = [ "woze" ];

  users.users.woze = {
    isNormalUser = true;
    hashedPassword = "$6$UViRjZMnBsCT7$U6tbj1.hFnQgxnN6pm5yaF2AiXsuVVxUGpBC3kMpDLyrUXOnocdxatx.Ffmalu8IzhhSA/i2EjpvlIOgSLLJS0";
    extraGroups = [ "wheel" "video" "input" "plugdev" "audio" ];
    shell = pkgs.fish;
  };
}
