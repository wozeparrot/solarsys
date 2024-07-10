{ pkgs, ... }:
{
  # mpd service with fft output
  services.mpd = {
    enable = true;
    musicDirectory = "/home/woze/music";
    extraConfig = ''
      bind_to_address "/tmp/mpd.socket"
      bind_to_address "10.11.235.99"

      audio_output {
        type "pipewire"
        name "Pipewire"
      }

      audio_output {
        type "fifo"
        name "Visualizer feed"
        path "/tmp/mpd.fifo"
        format "48000:16:2"
      }

      audio_output {
        type "httpd"
        name "HTTP stream"
        encoder "opus"
        port "8000"
        bitrate "160000"
        format "44100:16:2"
        always_on "yes"
        tags "yes"
      }

      replaygain "auto"

      auto_update "yes"
    '';
  };

  # mpdris2 for kdeconnect
  services.mpdris2 = {
    enable = true;
    package = pkgs.mpdris2.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "wozeparrot";
        repo = "mpdris2";
        rev = "89234c37416dd330bb54f199cbf6d2cf53deef47";
        sha256 = "sha256-6nVmipRFdW+YKYMrvAjtNJtA2AMZxPTiTFbP5Zi7G2M=";
      };
    });

    notifications = false;
  };

  # custom ncmpcpp
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      mpd_host = "/tmp/mpd.socket";

      visualizer_data_source = "/tmp/mpd.fifo";
      visualizer_output_name = "Visualizer feed";
      visualizer_in_stereo = "no";
      visualizer_type = "wave";
      visualizer_fps = "60";
      visualizer_autoscale = "yes";
      visualizer_spectrum_smooth_look = "yes";
      visualizer_color = "red";
      visualizer_look = "██";

      user_interface = "alternative";
      startup_screen = "playlist";
      cyclic_scrolling = "yes";
      progressbar_look = "━━━";

      now_playing_prefix = "$b$8>$9$/b";
      now_playing_suffix = "$/b ";
      current_item_prefix = "$8$u";
      current_item_suffix = "$/u$9";

      song_status_format = "$b$7♫ $2%a $4⟫$3⟫ $8%t $4⟫$3⟫ $5%b ";
      song_list_format = " $2%t$9 $R$4%a$9 ";
      autocenter_mode = "yes";
      centered_cursor = "yes";

      header_text_scrolling = "yes";
      jump_to_now_playing_song_at_start = "yes";
      browser_display_mode = "classic";
      playlist_display_mode = "classic";
      search_engine_display_mode = "columns";
      selected_item_prefix = "* ";
      media_library_primary_tag = "album_artist";
    };
  };

  # cava
  programs.cava = {
    enable = true;
    settings = {
      general.framerate = 60;
      input.method = "pipewire";
      smoothing.noise_reduction = 33;
    };
  };

  # cavalier
  home.packages = with pkgs; [ cavalier ];
}
