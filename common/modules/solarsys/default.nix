{ config, lib, ... }:
let
  cfg = config.solarsys;
in
{
  options.solarsys = {
    planet = lib.mkOption {
      type = lib.types.str;
      description = "planet that this moon is in";
    };

    moons = lib.mkOption {
      type = lib.types.attrs;
      description = "list of moons";
    };
  };
}
