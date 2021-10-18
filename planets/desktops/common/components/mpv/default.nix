{ pkgs, ... }:
{
  home.packages = with pkgs; [ yt-dlp ];

  programs.mpv = {
    enable = true;
    package = pkgs.wrapMpv (
      pkgs.mpv-unwrapped.override {
        vapoursynthSupport = true;
      }
    ) {
      youtubeSupport = true;
      scripts = with pkgs.mpvScripts; [ mpris autoload ];
    };
    defaultProfiles = [ "gpu-hq" ];
    config = {
      force-window = true;
      pause = false;
      save-position-on-quit = true;
      osc = true;
      gpu-api = "auto";
      gpu-context = "wayland";

      hwdec = "auto-safe-copy";
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

      scale = "spline36";
      dscale = "mitchell";
      cscale = "mitchell";
      linear-downscaling = false;
      sigmoid-upscaling = false;

      demuxer-mkv-subtitle-preroll = true;

      script-opts-append = "ytdl_hook-ytdl_path=yt-dlp";

      native-keyrepeat = true;
    };
    bindings = {
      b = "vf toggle format=colorlevels=full";
      g = "cycle deband";

      # Shader toggles
      "Alt+z" = "no-osd change-list glsl-shaders set \"~~/shaders/sssr.glsl:~~/shaders/ssd.glsl\"; show-text \"SS Shaders\"";

      "Alt+x" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Moderate_S.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Modern 1080p->4K (Fast)\"";
      "Alt+c" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Moderate_S.glsl\"; show-text \"Anime4K: Modern 1080p (Fast)\"";
      "Alt+," = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Moderate_UL.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_UL.glsl\"; show-text \"Anime4K: Modern 1080p->4K (HQ)\"";
      "Alt+." = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Moderate_UL.glsl\"; show-text \"Anime4K: Modern 1080p (HQ)\"";

      "Alt+v" = "no-osd change-list glsl-shaders set \"~~/shaders/acme-0_5x.glsl\"; show-text \"ACME 0.5x\"";

      "Alt+m" = "no-osd change-list glsl-shaders pre \"~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl\"; show-text \"Prepended Anime4K Clamp\"";
      "Alt+g" = "no-osd change-list glsl-shaders add \"~~/shaders/kb.glsl\"; show-text \"Appended KrigBilateral\"";
      "Alt+b" = "no-osd change-list glsl-shaders toggle \"~~/shaders/adaptive-sharpen.glsl\"; show-text \"Toggled Adaptive Sharpen\"";

      "Alt+n" = "no-osd change-list glsl-shaders clr \"\"; show-text \"GLSL shaders cleared\"";
    };
  };

  xdg.configFile = {
    mpv-shaders = {
      source = ./shaders;
      target = "mpv/shaders";
    };

    ff2mpv = {
      source = ./ff2mpv;
      target = "mpv/ff2mpv";
      executable = true;
    };
  };
}
