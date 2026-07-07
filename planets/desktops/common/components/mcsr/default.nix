{ pkgs, lib, ... }:
{
  programs.waywall = {
    enable = true;
    config = {
      enableWaywork = true;
      programs = [ pkgs.mcsr-nixos.ninjabrain-bot ];
      files = {
        overlay = ./overlay.png;
        crosshair = ./crosshair.png;
      };
      source = ./waywall.lua;
    };
  };

  programs.ninjabrain-bot = {
    enable = false;
    stylix = true;

    settings = {
      check_for_updates = false;

      hotkey_decrement.key = 57419;
      hotkey_increment.key = 57421;

      hotkey_lock.key = 23;
      hotkey_reset = {
        key = 19;
        modifiers = [ "ALT_L" ];
      };

      view = "detailed";
      all_advancements = false;
      mc_version = "pre_119";
      sensitivity = 0.02291165;

      default_boat_type = "green";
      alt_clipboard_reader = false;
      angle_adjustment_display_type = "increments";
      angle_adjustment_type = "tall";
      auto_reset = false;
      color_negative_coords = true;
      direction_help_enabled = true;
      show_angle_errors = true;
      show_angle_updates = true;
      sigma_boat = 0.0007;
      stronghold_display_type = "fourfour";
      use_adv_statistics = true;
      use_precise_angle = true;

      enable_http_server = false;
    };
  };
}
