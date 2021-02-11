{ pkgs, mpkgs, ... }:

{
  imports = [
    ./components/neovim
    ./components/intershell
    ./components/git
  ];

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
    libsForQt5.kdenlive

    gitAndTools.hub

    ss.multimc
    mpkgs.steam-run
    protontricks
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
    etcher

    unzip
    p7zip

    ss.discord
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
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      visualizer_fifo_path = "/tmp/mpd.fifo";
      visualizer_output_name = "my_fifo";
      visualizer_sync_interval = "12";
      visualizer_in_stereo = "no";
      visualizer_type = "spectrum";
      visualizer_look = "+|";
      visualizer_color = "red";

      user_interface = "alternative";
      cyclic_scrolling = "yes";
      progressbar_look = "─⊙_";

      now_playing_prefix = "> ";
      song_status_format = "$b$7♫ $2%a $4⟫$3⟫ $8%t $4⟫$3⟫ $5%b ";
      song_columns_list_format = "(6)[]{} (23)[red]{a} (26)[yellow]{t|f} (40)[green]{b} (4)[blue]{l}";
      song_list_format = " $7%l  $2%t $R$5%a ";
      autocenter_mode = "yes";
      centered_cursor = "yes";

      header_text_scrolling = "yes";
      jump_to_now_playing_song_at_start = "yes";
      browser_display_mode = "columns";
      selected_item_prefix = "* ";
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

  services.mpdris2 = {
    enable = true;
    notifications = true;
  };

  services.kdeconnect.enable = true;

  # systemd
  systemd.user.services.keepassxc = {
    Unit = {
      Description = "KeePassXC password manager";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = { ExecStart = "${pkgs.keepassxc}/bin/keepassxc"; };
  };

  # x config
  xdg.enable = true;

  # home manager stuff
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
