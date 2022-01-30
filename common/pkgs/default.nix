self: super:
{
  ss = {
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    rivercarro = self.callPackage ./rivercarro { };
    river = self.callPackage ./river { };
    shotcut = self.libsForQt5.callPackage ./shotcut { };

    matrix-conduit = self.callPackage ./matrix-conduit { };
  };

  yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
}
