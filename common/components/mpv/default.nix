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

      glsl-shader = "~~/shaders/sssr.glsl";
      scale = "haasnsoft";
      dscale = "mitchell";
      cscale = "ewa_lanczossoft";

      demuxer-mkv-subtitle-preroll = true;
    };
    bindings = {
      b = "vf toggle format=colorlevels=full";
    };
  };

  xdg.configFile = {
    mpv-sssr-glsl = {
      text = builtins.readFile ./sssr.glsl;
      target = "mpv/shaders/sssr.glsl";
    };
    
    # mpv-thumbnail-script-server-0 = {
    #   text = builtins.readFile ./mpv_thumbnail_script_server.lua;
    #   target = "mpv/scripts/mpv_thumbnail_script_server-0.lua";
    # };
    # mpv-thumbnail-script-server-1 = {
    #   text = builtins.readFile ./mpv_thumbnail_script_server.lua;
    #   target = "mpv/scripts/mpv_thumbnail_script_server-1.lua";
    # };
    # mpv-thumbnail-script-server-2 = {
    #   text = builtins.readFile ./mpv_thumbnail_script_server.lua;
    #   target = "mpv/scripts/mpv_thumbnail_script_server-2.lua";
    # };
    # mpv-thumbnail-script-server-3 = {
    #   text = builtins.readFile ./mpv_thumbnail_script_server.lua;
    #   target = "mpv/scripts/mpv_thumbnail_script_server-3.lua";
    # };

    # mpv-thumbnail-script-client-osc = {
    #   text = builtins.readFile ./mpv_thumbnail_script_client_osc.lua;
    #   target = "mpv/scripts/mpv_thumbnail_script_client_osc.lua";
    # };

    # mpv-thumbnail-script-config = {
    #   text = ''
    #     thumbnail_network=yes
    #   '';
    #   target = "mpv/script-opts/mpv_thumbnail_script.conf";
    # };

    ff2mpv = {
      text = builtins.readFile ./ff2mpv;
      target = "mpv/ff2mpv";
      executable = true;
    };
  };
}
