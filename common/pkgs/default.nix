self: super:
{
  ss-multimc = super.multimc;#self.qt5.callPackage ./pkgs/multimc { };
  ss-discord = super.discord;#self.callPackage ./pkgs/discord { };
  ss-rofi = super.rofi;#self.callPackage ./pkgs/rofi { };
  ss-picom = super.picom;#self.callPackage ./pkgs/picom { };
}
