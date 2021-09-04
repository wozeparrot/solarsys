{ ... }: {
  networking.hostName = "anime-nas";

  imports = [
    ../common/profiles/rpi4.nix
  ];

  system.stateVersion = "21.11";
}
