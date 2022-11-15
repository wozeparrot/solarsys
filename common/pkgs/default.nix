self: super: {
  ss = rec {
    ardour = self.callPackage ./ardour {};
    discord-canary = self.callPackage ./discord {branch = "canary";};
    horizon = self.callPackage ./horizon {};
    lmms = self.libsForQt5.callPackage ./lmms {};
    onagre = self.callPackage ./onagre {inherit pop-launcher;};
    pop-launcher = self.callPackage ./pop-launcher {};
    river = self.callPackage ./river {};
    rivercarro = self.callPackage ./rivercarro {};
    shotcut = self.libsForQt5.callPackage ./shotcut {};
    sonobus = self.callPackage ./sonobus {};
    zrythm = self.callPackage ./zrythm {};
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
    extraPkgs = pkgs: with pkgs; [
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
  android-tools = self.master.android-tools;
}
