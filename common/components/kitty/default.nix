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

      foreground = "#c6c6c6";
      background = "#000000";
      color0 = "#1a1a1a";
      color8 = "#444444";
      color1 = "#ac2c2c";
      color9 = "#af5f87";
      color2 = "#4e9a06";
      color10 = "#87af87";
      color3 = "#c4a000";
      color11 = "#d7af5f";
      color4 = "#1880bc";
      color12 = "#369dd8";
      color5 = "#75507b";
      color13 = "#af87d7";
      color6 = "#389aad";
      color14 = "#34e2e2";
      color7 = "#9e9e9e";
      color15 = "#b2b2b2";

      background_opacity = "0.9";

      hide_window_decorations = "no";
      window_padding_width = 2;
    };
  };
}
