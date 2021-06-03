self: super:
{
  discord-canary = super.discord-canary.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download/canary?platform=linux&format=tar.gz";
        sha256 = "1za7192acs46l408x6qxsa06k494sy67j1gds2f4zqnz7j81mjxv";
      };
      nativeBuildInputs = [ super.xorg.libxshmfence ];
    }
  );
}
