self: super:
{
  ss = {
    multimc = self.qt5.callPackage ./multimc { };
    discord = self.callPackage ./discord { };
    rofi = self.callPackage ./rofi { };
    picom = self.callPackage ./picom { };
    neovim-nightly = self.callPackage ./neovim-nightly { };
    arcan = self.callPackage ./arcan { };
    zig-master = self.callPackage ./zig-master { };
  };
}
