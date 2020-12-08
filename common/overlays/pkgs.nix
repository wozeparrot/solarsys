self: super:
{
  ss-multimc = self.qt5.callPackage ./pkgs/multimc { };
  ss-discord = self.callPackage ./pkgs/discord { };
  ss-rofi = self.callPackage ./pkgs/rofi { };
  ss-picom = self.callPackage ./pkgs/picom { };
}
