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
      ytdl-format = "bestvideo[height<=?1080]+bestaudio";
      save-position-on-quit = true;
      osc = false;

      hwdec = "auto-copy";
      hwdec-codecs = "all";
      hr-seek-framedrop = false;

      profile = "gpu-hq";
      gpu-api = "vulkan";

      alang = "jpn,jp,eng,en";
      slang = "eng,en,enUS";

      deband = true;
      deband-iterations = 2;
      deband-threshold = 35;
      deband-range = 20;
      deband-grain = 5;

      dither-depth = "auto";

      blend-subtitles = true;

      scale = "ewa_lanczossharp";
      dscale = "mitchell";
      cscale = "ewa_lanczossoft";
    };
  };
}
