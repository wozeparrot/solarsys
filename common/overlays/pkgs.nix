self: super:
{
  multimc = super.callPackage ./pkgs/multimc { };
  discord = super.callPackage ./pkgs/discord { };
}
