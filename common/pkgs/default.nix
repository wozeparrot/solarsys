self: super:
{
  ss = {
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    rivercarro = self.callPackage ./rivercarro { };
    river = self.callPackage ./river { };
    shotcut = self.libsForQt5.callPackage ./shotcut { };
    lmms = self.libsForQt5.callPackage ./lmms { };
    zrythm = self.callPackage ./zrythm { };

    matrix-conduit = self.callPackage ./matrix-conduit { };

    goosemod = {
      openasar = self.callPackage ./goosemod-openasar { };
    };
  };

  yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
  matrix-appservice-discord = self.callPackage ./matrix-appservice-discord { };
}
