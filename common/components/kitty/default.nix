{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font 9";
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;

      tab_bar_style = "powerline";

      cursor = "#345db5";
      cursor_text_color = "#180e1a";
      foreground = "#5d7cbf";
      foreground = "#5d7cbf";
      color0 = "#180e1a";
      color8 = "#40558c";
      color1 = "#b867a9";
      color9 = "#c542ac";
      color2 = "#a28bcb";
      color10 = "#221e2e";
      color3 = "#b16bd6";
      color11 = "#1d2748";
      color4 = "#b74ec5";
      color12 = "#6b4f8d";
      color5 = "#b16bd6";
      color13 = "#283557";
      color6 = "#5495cf";
      color14 = "#b16bd6";
      color7 = "#345db5";
      color15 = "#4a3662";

      background_opacity = 0.8;
    };
  };
}
