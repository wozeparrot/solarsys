self: super: {
  ss = rec {
    discord-canary = self.callPackage ./discord {branch = "canary";};
    rivercarro = self.callPackage ./rivercarro {};
    river = self.callPackage ./river {};
    shotcut = self.libsForQt5.callPackage ./shotcut {};
    lmms = self.libsForQt5.callPackage ./lmms {};
    zrythm = self.callPackage ./zrythm {};
    horizon = self.callPackage ./horizon {};
    pop-launcher = self.callPackage ./pop-launcher {};
    onagre = self.callPackage ./onagre {inherit pop-launcher;};
    sonobus = self.callPackage ./sonobus {};
    zscroll = self.callPackage ./zscroll {};

    matrix-conduit = self.callPackage ./matrix-conduit {};

    goosemod = {
      openasar = self.callPackage ./goosemod-openasar {};
      discord-canary = self.callPackage ./goosemod-discord {
        branch = "canary";
        inherit goosemod;
      };
    };

    pam-python = self.callPackage ./pam-python {};
    howdy = self.callPackage ./howdy {};
  };

  # yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
  matrix-appservice-discord = self.callPackage ./matrix-appservice-discord {};

  steam = self.master.steam.override {
    extraPkgs = pkgs: with pkgs;
      [
        keyutils
        libkrb5
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        xorg.libXScrnSaver
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
      ];
  };
}
