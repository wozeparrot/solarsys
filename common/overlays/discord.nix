self: super:
{
  discord-canary = super.discord-canary.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download/canary?platform=linux&format=tar.gz";
        sha256 = super.lib.fakeSha256;
      };
    }
  );
}
