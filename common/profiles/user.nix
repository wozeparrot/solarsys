{ config, pkgs, mpkgs, lib, ... }:
{
  nix.trustedUsers = [ "woze" ];

  users.users.woze = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "plugdev" ];
    shell = pkgs.fish;
  };
};
