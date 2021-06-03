self: super:
{
  ss = {
    multimc = self.qt5.callPackage ./multimc { };
    discord = self.callPackage ./discord { branch = "canary"; };
    rofi = self.callPackage ./rofi { };
    picom = self.callPackage ./picom { };
    arcan = self.callPackage ./arcan { };
    zig-master = self.callPackage ./zig-master { };
  };
}
