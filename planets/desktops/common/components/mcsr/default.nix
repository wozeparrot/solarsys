{ pkgs, lib, ... }:
{
  programs.waywall = {
    enable = true;
    config = {
      enableWaywork = true;
      programs = [ pkgs.mcsr-nixos.ninjabrain-bot ];
      files = {
        overlay = ./overlay.png;
        crosshair = ./crosshair.png;
      };
      source = ./waywall.lua;
    };
  };
}
