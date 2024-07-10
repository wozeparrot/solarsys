{ pkgs, ... }:
{
  home.packages = with pkgs; [ shfm ];

  xdg.configFile."shfm/opener.sh" = {
    executable = true;
    source = ./opener.sh;
  };
  home.sessionVariables."SHFM_OPENER" = "$HOME/.config/shfm/opener.sh";
}
