# interactive shell config
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ gh-copilot ];

  programs = {
    fish = {
      enable = true;

      interactiveShellInit = ''
        # color scheme
        # set -U fish_color_normal normal
        # set -U fish_color_command c397d8
        # set -U fish_color_quote b9ca4a
        # set -U fish_color_redirection 70c0b1
        # set -U fish_color_end c397d8
        # set -U fish_color_error d54e53
        # set -U fish_color_param 7aa6da
        # set -U fish_color_selection white --bold --background=brblack
        # set -U fish_color_search_match bryellow --background=brblack
        # set -U fish_color_history_current --bold
        # set -U fish_color_operator 00a6b2
        # set -U fish_color_escape 00a6b2
        # set -U fish_color_cwd green
        # set -U fish_color_cwd_root red
        # set -U fish_color_valid_path --underline
        # set -U fish_color_autosuggestion 969896
        # set -U fish_color_user brgreen
        # set -U fish_color_host normal
        # set -U fish_color_cancel -r
        # set -U fish_pager_color_completion normal
        # set -U fish_pager_color_description B3A06D yellow
        # set -U fish_pager_color_prefix white --bold --underline
        # set -U fish_pager_color_progress brwhite --background=cyan
        # set -U fish_color_match --background=brblue
        # set -U fish_color_comment e7c547

        set -x GOPATH ~/local/Go
        set -x PYTHONPYCACHEPREFIX ~/.cache/python/
        set -x HISTSIZE 20000
        set -x HISTFILESIZE 20000

        source ("${pkgs.starship}/bin/starship" init fish --print-full-init | psub)

        complete -c nom --wraps nix

        set -p fish_complete_path ${config.programs.fish.package}/share/fish/completions
      '';
      plugins = [
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "067e867debee59aee231e789fc4631f80fa5788e";
            hash = "sha256-emmjTsqt8bdI5qpx1bAzhVACkg0MNB/uffaRjjeuFxU=";
          };
        }
      ];

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
        mpvclf = {
          body = ''
            mpv --vf=format=colorlevels=full $argv
          '';
        };
        ytdlmu = {
          body = ''
            yt-dlp -x --audio-quality 0 --audio-format flac --yes-playlist --embed-metadata -o "%(title)s.%(ext)s" $argv
          '';
        };
        x11waymir = {
          body = ''
            SDL_VIDEODRIVER=x11 wf-recorder -c rawvideo -m sdl -f pipe:xwayland-mirror
          '';
        };
      };
    };

    starship.enable = true;
    starship.settings = {
      character.success_symbol = "[➜](bold green)";
      character.error_symbol = "[➜](bold red)";

      cmd_duration.min_time = 500;
      cmd_duration.format = "took [$duration](bold yellow)";
    };
  };
}
