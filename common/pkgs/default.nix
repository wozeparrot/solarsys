self: super:
{
  ss = {
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    rivercarro = self.callPackage ./rivercarro { };
    river-debug = self.callPackage ./river { };
    shotcut = self.callPackage ./shotcut { };
  };
}
