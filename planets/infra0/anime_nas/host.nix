{ ... }: {
  imports = [
    ../common/profiles/rpi4.nix
  ];

  networking.hostName = "anime_nas";

  system.stateVersion = "21.11";
}
