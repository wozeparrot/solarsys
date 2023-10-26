{pkgs, lib, ...}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "Agave Nerd Font";
      size = 12;
    };
    settings = {
      editor = "nvim";
      disable_ligatures = "cursor";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;

      # background = "#000000";
      # foreground = "#d2cad3";
      # color0 = "#08040b";
      # color8 = "#554d5b";
      # color1 = "#a52e4d";
      # color9 = "#fa83a2";
      # color2 = "#228039";
      # color10 = "#44a29f";
      # color3 = "#996f06";
      # color11 = "#ddc47d";
      # color4 = "#006fc1";
      # color12 = "#6691d2";
      # color5 = "#aa3c9f";
      # color13 = "#c29dd5";
      # color6 = "#33b3f4";
      # color14 = "#88c4f4";
      # color7 = "#bbb3c1";
      # color15 = "#f8f0f8";

      background_opacity = lib.mkForce "0.88";

      hide_window_decorations = "no";
      window_padding_width = 8;

      allow_remote_control = true;
    };
  };
}
