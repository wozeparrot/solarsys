self: super:
{
  ss = {
    discord-canary = self.callPackage ./discord { branch = "canary"; };
    rivercarro = self.callPackage ./rivercarro { };
  };
}
