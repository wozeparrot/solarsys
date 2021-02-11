{ pkgs, ... }:
{
  # mpd service with fft output
  services.mpd = {
    enable = true;
    extraConfig = ''
      audio_output {
        type "pulse"
        name "pulse audio"
      }

      audio_output {
        type "fifo"
        name "my_fifo"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }
    '';
  };

  # mpdris2 for kdeconnect
  services.mpdris2 = {
    enable = true;
    notifications = true;
  };

  # custom ncmpcpp
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      visualizer_fifo_path = "/tmp/mpd.fifo";
      visualizer_output_name = "my_fifo";
      visualizer_sync_interval = "12";
      visualizer_in_stereo = "no";
      visualizer_type = "spectrum";
      visualizer_look = "||";
      visualizer_color = "green";

      user_interface = "alternative";
      cyclic_scrolling = "yes";
      progressbar_look = "─⊙_";

      now_playing_prefix = "> ";
      song_status_format = "$b$7♫ $2%a $4⟫$3⟫ $8%t $4⟫$3⟫ $5%b ";
      song_columns_list_format = "(6)[]{} (23)[red]{a} (26)[yellow]{t|f} (40)[green]{b} (4)[blue]{l}";
      song_list_format = " $7%l  $2%t $R$5%a ";
      autocenter_mode = "yes";
      centered_cursor = "yes";

      header_text_scrolling = "yes";
      jump_to_now_playing_song_at_start = "yes";
      browser_display_mode = "columns";
      selected_item_prefix = "* ";
    };
  };
}
