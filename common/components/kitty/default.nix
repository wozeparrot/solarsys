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

      foreground = "#DEDBEB";
      background = "#2A2331";
      color0 = "#28222d";
      color8 = "#302838";
      color1 = "#ed3f7f";
      color9 = "#fb5c8e";
      color2 = "#a2baa8";
      color10 = "#bfd1c3";
      color3 = "#eacac0";
      color11 = "#f0ddd8";
      color4 = "#9985d1";
      color12 = "#b4a4de";
      color5 = "#e68ac1";
      color13 = "#edabd2";
      color6 = "#aabae7";
      color14 = "#c4d1f5";
      color7 = "#dedbeb";
      color15 = "#edebf7";

      background_opacity = "0.8";

      hide_window_decorations = "no";
      window_padding_width = 2;
    };
  };
}