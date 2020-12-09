self: super:
{
  ss = {
    multimc = self.qt5.callPackage ./multimc { };
    discord = self.callPackage ./discord { };
    rofi = self.callPackage ./rofi { };
    picom = self.callPackage ./picom { };
  };
}
