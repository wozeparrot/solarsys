self: super:
{
  ss = {
    discord-canary = self.callPackage ./discord { branch = "canary"; useWayland = true; };
    rivercarro = self.callPackage ./rivercarro { };
    river = self.callPackage ./river { };
    shotcut = self.libsForQt5.callPackage ./shotcut { };
  };

  yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
}
