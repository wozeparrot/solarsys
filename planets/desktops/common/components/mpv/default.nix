{ pkgs, ... }:
{
  home.packages = with pkgs; [ yt-dlp ];

  programs.mpv = {
    enable = true;
    package = pkgs.mpv-unwrapped.wrapper {
      mpv = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
      youtubeSupport = true;
      scripts = with pkgs.mpvScripts; [
        evafast
        mpris
        thumbfast
        uosc
        videoclip
      ];
    };
    defaultProfiles = [ "gpu-hq" ];
    config = {
      vo = "gpu-next";

      force-window = true;
      pause = false;
      save-position-on-quit = true;
      border = false;
      gpu-api = "auto";
      gpu-context = "wayland";

      hwdec = false;
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
      temporal-dither = true;

      blend-subtitles = true;

      scale = "ewa_robidouxsharp";
      dscale = "ewa_robidouxsharp";
      cscale = "ewa_robidouxsharp";
      linear-downscaling = false;
      correct-downscaling = true;
      sigmoid-upscaling = true;

      # tone-mapping = "clip";
      # gamut-mapping-mode = "clip";

      demuxer-mkv-subtitle-preroll = true;

      script-opts-append = "ytdl_hook-ytdl_path=yt-dlp";

      native-keyrepeat = true;
    };
    bindings = {
      b = "vf toggle format=colorlevels=full";
      g = "cycle deband";

      # Shader toggles
      "Alt+z" = "no-osd change-list glsl-shaders set \"~~/shaders/sssr.glsl:~~/shaders/ssd.glsl\"; show-text \"SS Shaders\"";

      "Alt+q" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode A (Fast)\"";
      "Alt+w" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode B (Fast)\"";
      "Alt+e" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode C (Fast)\"";
      "Alt+r" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_M.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode A+A (Fast)\"";
      "Alt+t" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_M.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_S.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode B+B (Fast)\"";
      "Alt+y" = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K/Anime4K_Restore_CNN_S.glsl:~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Mode C+A (Fast)\"";

      "Alt+v" = "no-osd change-list glsl-shaders set \"~~/shaders/acme-0_5x.glsl\"; show-text \"ACME 0.5x\"";

      "Alt+x" = "no-osd change-list glsl-shaders set \"~~/shaders/fsr.glsl:~~/shaders/cas-scaled.glsl\"; show-text \"FSR\"";
      "Alt+c" = "no-osd change-list glsl-shaders add \"~~/shaders/cas.glsl\"; show-text \"Appended CAS\"";

      "Alt+m" = "no-osd change-list glsl-shaders pre \"~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl\"; show-text \"Prepended Anime4K Clamp\"";
      "Alt+g" = "no-osd change-list glsl-shaders add \"~~/shaders/kb.glsl\"; show-text \"Appended KrigBilateral\"";
      "Alt+b" = "no-osd change-list glsl-shaders toggle \"~~/shaders/adaptive-sharpen-anime.glsl\"; show-text \"Toggled Adaptive Sharpen Anime\"";
      "Alt+Shift+b" = "no-osd change-list glsl-shaders toggle \"~~/shaders/adaptive-sharpen.glsl\"; show-text \"Toggled Adaptive Sharpen\"";

      "Alt+n" = "no-osd change-list glsl-shaders clr \"\"; show-text \"GLSL shaders cleared\"";

      "Alt+-" = "add video-zoom -0.25";
      "Alt+=" = "add video-zoom 0.25";
    };
  };

  xdg.configFile = {
    mpv-shaders = {
      source = ./shaders;
      target = "mpv/shaders";
    };

    mpv-scripts = {
      source = ./scripts;
      target = "mpv/scripts";
    };

    mpv-fonts = {
      source = ./fonts;
      target = "mpv/fonts";
    };

    ff2mpv = {
      source = ./ff2mpv;
      target = "mpv/ff2mpv";
      executable = true;
    };
  };
}
