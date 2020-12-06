{ pkgs, mpkgs, ... }:

{
  imports = [ ./components/neovim ./components/intershell ];

  # packages
  home.packages = with pkgs; [
    vscode

    gdb
    rustup
    nixpkgs-fmt
    python3
    go

    blender
    godot
    gimp
    kdeApplications.kdenlive

    gitAndTools.hub
    
    customGamesPkgs.multimc
    mpkgs.steam
    mpkgs.steam-run
    lutris

    xdo
    xdotool
    shotgun
    arandr
    xclip
    slop
    flameshot

    ranger
    feh

    mpc_cli
    neofetch
    onefetch
    bottom
    python3Packages.ueberzug
    iotop

    keepassxc

    unzip
    p7zip

    customGooseModPkg
  ];

  # extra programs
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.alacritty.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "~/music";
    settings = {
      visualizer_fifo_path = "/tmp/mpd.fifo";
      visualizer_output_name = "my_fifo";
      visualizer_sync_interval = "30";
      visualizer_in_stereo = "yes";
      visualizer_type = "wave";
      visualizer_look = "+|";
    };
  };

  # extra services
  services.mpd = {
    enable = true;
    extraConfig = ''
      audio_output {
        type "pulse"
        name "pulse audio"
      }

      audio_output {
        type "fifo"
        name "my_fifo"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }
    '';
  };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    VISUAL = "nvim";
    EDITOR = "nvim";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  home.username = "woze";
  home.homeDirectory = "/home/woze";

  programs.home-manager.enable = true;
  home.stateVersion = "20.09";
}
