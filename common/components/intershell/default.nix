# interactive shell config
{ config, pkgs, mpkgs, lib, ... }:
let
  fishConfig = '''
    # color scheme
    set -u fish_color_autosuggestion:875f87
    set -u fish_color_cancel:normal
    set -u fish_color_command:5f5fff
    set -u fish_color_comment:990000
    set -u fish_color_cwd:008000
    set -u fish_color_cwd_root:800000
    set -u fish_color_end:009900
    set -u fish_color_error:ff0000
    set -u fish_color_escape:00a6b2
    set -u fish_color_history_current:normal
    set -u fish_color_host:normal
    set -u fish_color_host_remote:yellow
    set -u fish_color_match:normal
    set -u fish_color_normal:normal
    set -u fish_color_operator:00a6b2
    set -u fish_color_param:d700ff
    set -u fish_color_quote:d7005f
    set -u fish_color_redirection:00afff
    set -u fish_color_search_match:ffff00
    set -u fish_color_selection:c0c0c0
    set -u fish_color_status:red
    set -u fish_color_user:00ff00
    set -u fish_color_valid_path:normal
    set -u fish_pager_color_completion:normal
    set -u fish_pager_color_description:B3A06D\x1eyellow
    set -u fish_pager_color_prefix:white\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
    set -u fish_pager_color_progress:brwhite\x1e\x2d\x2dbackground\x3dcyan

    set -x GOPATH ~/local/Go
    set -x HISTSIZE=20000
    set -x HISTFILESIZE=20000

    function ccd
      mkdir -p "$argv"
      and cd "$argv"
    end

    function clipb
      cat "$argv" | xclip -selection clipboard
    end
  '';
in
{
  programs.fish = {
    enable = true;

    interactiveShellInit = fishConfig;

    functions = {
      fish_greeting = {
        body = "";
      };
      ccd = {
        body = ''
          mkdir -p "$argv"
          and cd "$argv"
        '';
      };
      clipb = {
        body = ''
          cat "$argv" | xclip -selection clipboard
        '';
      };
    };

    promptInit = ''
      source ("${pkgs.starship}/bin/starship init fish --print-full-init | psub")
    '';
  };

  programs.starship.enable = true;
  programs.starship.settings = {
    character.success_symbol = "[➜](bold green)";
    character.error_symbol = "[➜](bold red)";

    cmd_duration.min_time = 500;
    cmd_duration.format = "took [$duration](bold yellow)";
  };
}
