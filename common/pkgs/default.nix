self: super:
{
  ss = rec {
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    rivercarro = self.callPackage ./rivercarro { };
    river = self.callPackage ./river { };
    shotcut = self.libsForQt5.callPackage ./shotcut { };
    lmms = self.libsForQt5.callPackage ./lmms { };
    zrythm = self.callPackage ./zrythm { };
    horizon = self.callPackage ./horizon { };

    matrix-conduit = self.callPackage ./matrix-conduit { };

    goosemod = {
      openasar = self.callPackage ./goosemod-openasar { };
      discord-canary = self.callPackage ./goosemod-discord { branch = "canary"; inherit goosemod; };
    };
  };

  yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
  matrix-appservice-discord = self.callPackage ./matrix-appservice-discord { };
}
