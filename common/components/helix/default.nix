{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    mpkgs.helix
  ];
}
