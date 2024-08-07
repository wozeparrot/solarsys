{
  branch ? "stable",
  pkgs,
  goosemod,
}:
# Generated by ./update-discord.sh
let
  inherit (pkgs) callPackage fetchurl;
in
{
  stable = callPackage ./base.nix rec {
    inherit goosemod;
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord GM";
    version = "0.0.19";
    src = fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "1403vdc7p6a8mhr114brfp4dqvikaj5s71wrx20ca5y6srsv5x0r";
    };
  };
  ptb = callPackage ./base.nix rec {
    inherit goosemod;
    pname = "discord-ptb";
    binaryName = "DiscordPTB";
    desktopName = "Discord PTB GM";
    version = "0.0.33";
    src = fetchurl {
      url = "https://dl-ptb.discordapp.net/apps/linux/${version}/discord-ptb-${version}.tar.gz";
      sha256 = "0887ncnbiab3h17bbgqz8mjjrgg6fcdkwpi1vcf1ghl6bfa9dsrp";
    };
  };
  canary = callPackage ./base.nix rec {
    inherit goosemod;
    pname = "discord-canary";
    binaryName = "DiscordCanary";
    desktopName = "Discord Canary GM";
    version = "0.0.139";
    src = fetchurl {
      url = "https://dl-canary.discordapp.net/apps/linux/${version}/discord-canary-${version}.tar.gz";
      sha256 = "1llafigs2zd49m212d49zi4klx39kn4r2msxz75cmi4i6p8wxxzw";
    };
  };
}
.${branch}
