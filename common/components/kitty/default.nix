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
      color0 = "#151510";
      color8 = "#353530";
      color1 = "#852852";
      color9 = "#e83c6a";
      color2 = "#009400";
      color10 = "#00ee37";
      color3 = "#df5a32";
      color11 = "#fe9a43";
      color4 = "#344875";
      color12 = "#6273a4";
      color5 = "#3713cd";
      color13 = "#7d36f4";
      color6 = "#005ba5";
      color14 = "#00afff";
      color7 = "#949494";
      color15 = "#b4b4b4";

      background_opacity = "0.9";

      hide_window_decorations = "no";
      window_padding_width = 2;
    };
  };
}
