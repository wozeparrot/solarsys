self: super:
{
  ss-multimc = super.callPackage ./pkgs/multimc { };
  ss-discord = super.callPackage ./pkgs/discord { };
  ss-rofi = super.callPackage ./pkgs/rofi { };
  ss-picom = super.callPackage ./pkgs/picom { };
}
