self: super: {
  ss = rec {
    ardour = self.callPackage ./ardour { };
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    lmms = self.libsForQt5.callPackage ./lmms { };
    onagre = self.callPackage ./onagre { inherit pop-launcher; };
    pop-launcher = self.callPackage ./pop-launcher { };
    river = self.callPackage ./river { };
    rivercarro = self.callPackage ./rivercarro { };
    shotcut = self.libsForQt5.callPackage ./shotcut { };
    sonobus = self.callPackage ./sonobus { };
    veikk-driver = self.callPackage ./veikk-driver { };
    zrythm = self.callPackage ./zrythm { };

    matrix-conduit = self.callPackage ./matrix-conduit { };

    goosemod = {
      openasar = self.callPackage ./goosemod-openasar { };
      discord-canary = self.callPackage ./goosemod-discord {
        branch = "canary";
        inherit goosemod;
      };
    };

    motioneye = self.callPackage ./motioneye { };

    speedtest-exporter = self.callPackage ./speedtest-exporter { };

    mods = self.callPackage ./mods { };

    xencelabs = self.libsForQt5.callPackage ./xencelabs { };

    vulkan-hdr-layer = self.callPackage ./vulkan-hdr-layer { };
  };

  # yt-dlp = self.python3Packages.callPackage ./yt-dlp { };
  matrix-appservice-discord = self.callPackage ./matrix-appservice-discord { };

  steam = self.master.steam.override {
    extraPkgs =
      pkgs: with pkgs; [
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
  inherit (self.master) android-tools;
}
