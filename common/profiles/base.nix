{ config, pkgs, mpkgs, lib, inputs, ... }:
{
  imports = [
    ./user.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    registry.nixpkgs.flake = inputs.unstable;

    nixPath = [ "nixpkgs=${inputs.unstable}" ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      min-free = 536870912
    '';
  };

  nixpkgs.config.allowUnfree = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment = {
    systemPackages = with pkgs; [
      # core system utils
      coreutils
      binutils

      # config building
      git
      gnumake

      # extra utils
      ripgrep
      htop
      curl
      wget
      file
      less
      nano
      vim

      # network utils
      dnsutils
      nmap
    ];

    shellAliases = {
      # grep
      grep = "rg";

      # my public ip
      myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
    };

    sessionVariables = {
      PAGER = "less";
      LESS = "-iFJMRWX -z-4 -x4";
      LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    };

    homeBinInPath = true;
  };

  # fonts
  fonts = {
    fonts = with pkgs; [ nerdfonts jetbrains-mono ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "JetBrainsMono" ];
    };
  };

  # extra programs
  programs.thefuck.enable = true;
  programs.firejail.enable = true;
  programs.mtr.enable = true;
  programs.fish.enable = true;

  # services
  services.lorri.enable = true;

  ## oom killer
  services.earlyoom.enable = true;

  # disable manually creating users
  users.mutableUsers = false;
}
