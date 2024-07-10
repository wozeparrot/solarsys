# interactive shell config
{ config, pkgs, ... }:
let
  fishConfig = ''
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
    set -x HISTSIZE 20000
    set -x HISTFILESIZE 20000

    source ("${pkgs.starship}/bin/starship" init fish --print-full-init | psub)

    complete -c nom --wraps nix
  '';
in
{
  home.packages = with pkgs; [ github-copilot-cli ];

  programs = {
    fish = {
      enable = true;

      interactiveShellInit = fishConfig;
      plugins = [
        {
          name = "github-copilot-cli-fish";
          src = pkgs.fetchFromGitHub {
            owner = "z11i";
            repo = "github-copilot-cli.fish";
            rev = "ccb6367bbb3055ea19b9ff0eac1ccf1c5e86419a";
            hash = "sha256-cnmxvnG3WN2uqtt1aUEf0OFJulQSpFd3RJeeVKpDI9Y=";
          };
        }
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
            hash = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
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
