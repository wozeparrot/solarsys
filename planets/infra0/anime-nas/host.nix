{ ... }: {
  imports = [
    ../common/profiles/rpi4.nix
  ];

  networking.hostName = "anime-nas";

  system.stateVersion = "21.11";
}
