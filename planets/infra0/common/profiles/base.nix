{ pkgs, config, lib, ... }: {
  environment.noXlibs = lib.mkDefault true;
}
