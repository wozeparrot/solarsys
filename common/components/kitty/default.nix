{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font 6";
    };
    settings = {
      disable_ligatures = "cursor";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;

      tab_bar_style = "powerline";

      background = "#000000";
      foreground = "#d2d2cd";
      color0 = "#080808";
      color8 = "#555555";
      color1 = "#994455";
      color9 = "#ee99aa";
      color2 = "#228833";
      color10 = "#44aa99";
      color3 = "#997700";
      color11 = "#ddcc77";
      color4 = "#0077bb";
      color12 = "#6699cc";
      color5 = "#aa4499";
      color13 = "#c2a5cf";
      color6 = "#33bbee";
      color14 = "#88ccee";
      color7 = "#bbbbbb";
      color15 = "#f8f8f2";

      background_opacity = "0.9";

      hide_window_decorations = "no";
      window_padding_width = 2;
    };
  };
}
