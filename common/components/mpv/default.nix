{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { vapoursynthSupport = true; }) {
      youtubeSupport = true;
      scripts = with pkgs.mpvScripts; [ mpris autoload ];
    };
    config = {
      force-window = true;
      ytdl-format = "bestvideo[height<=?1080]+bestaudio";
      save-position-on-quit = true;
      osc = true;
      profile = "gpu-hq";
      gpu-api = "vulkan";
      gpu-context = "waylandvk";

      hwdec = "no";
      hwdec-codecs = "all";
      hr-seek-framedrop = false;

      alang = "jpn,jp,eng,en";
      slang = "eng,en,enUS";

      deband = true;
      deband-iterations = 2;
      deband-threshold = 35;
      deband-range = 20;
      deband-grain = 5;

      dither-depth = "auto";

      blend-subtitles = true;

      glsl-shader = "~~/shaders/sssr.glsl";
      scale = "haasnsoft";
      dscale = "mitchell";
      cscale = "ewa_lanczossoft";
    };
  };

  xdg.configFile.mpv-sssr-glsl = {
    text = builtins.readFile ./sssr.glsl;
    target = "mpv/shaders/sssr.glsl";
  };
}
