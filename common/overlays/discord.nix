self: super:
{
  discord-canary = super.discord-canary.overrideAttrs (
    _: {
      src = builtins.fetchTarball "https://discord.com/api/download/canary?platform=linux&format=tar.gz";
    }
  );
}
