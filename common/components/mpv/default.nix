{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { vapoursynthSupport = true; }) {
      youtubeSupport = true;
      scripts = with pkgs.mpvScripts; [ mpris autoload thumbnail ];
    };
    config = {
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      save-position-on-quit = true;
      osc = false;
    };
    defaultProfiles = [ "gpu-hq" ];
  };
}
