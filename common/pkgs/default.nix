self: super:
{
  ss-multimc = super.multimc;#self.qt5.callPackage ./multimc { };
  ss-discord = super.discord;#self.callPackage ./discord { };
  ss-rofi = super.rofi;#self.callPackage ./rofi { };
  ss-picom = self.callPackage ./picom { };
}
