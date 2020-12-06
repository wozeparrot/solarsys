{ config, pkgs, mpkgs, lib, ... }:
{
  nix.package = pkgs.nixFlakes;
  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.optimise.automatic = true;
  nix.allowedUsers = [ "@wheel" ];
  nix.trustedUsers = [ "root" "@wheel" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references
    min-free = 536870912
  '';

  environment = {
    systemPackages = with pkgs; [
      # core system utils
      coreutils
      binutils

      # git
      git

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

  # services
  services.lorri.enable = true;

  ## oom killer
  services.earlyoom.enable = true;

  # disable manually creating users
  users.mutableUsers = false;
}
