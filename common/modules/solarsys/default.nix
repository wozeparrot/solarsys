{ config, lib, ... }:
with lib;
let
  cfg = config.solarsys;
in
{
  options.solarsys = {
    planet = mkOption {
      type = types.str;
      description = "planet that this moon is in";
    };

    moons = mkOption {
      type = types.attrs;
      description = "list of moons";
    };
  };
}
