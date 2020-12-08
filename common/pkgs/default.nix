self: super:
{
  ss-multimc = self.qt5.callPackage ./multimc { };
  ss-discord = self.callPackage ./discord { };
  ss-rofi = self.callPackage ./rofi { };
  ss-picom = self.callPackage ./picom { };
}
