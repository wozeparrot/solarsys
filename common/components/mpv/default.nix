{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { vapoursynthSupport = true; }) {
      youtubeSupport = true;
      scripts = with pkgs.mpvScripts; [
        mpris
        autoload
        thumbnail
      ];
    };
    config = {
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
    defaultProfiles = [ "gpu-hq" ];
  };
}
