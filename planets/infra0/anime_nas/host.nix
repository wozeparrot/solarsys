{ ... }: {
  imports = [
    ../common/profiles/rpi4.nix
  ];

  networking.hostname = "anime_nas";

  system.stateVersion = "21.11";
}
