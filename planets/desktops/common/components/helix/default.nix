{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    master.helix
  ];
}
