{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  nix = {
    package = pkgs.nixUnstable;
    settings.system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];

    registry = let
      nixRegistry =
        builtins.mapAttrs (_: v: {flake = v;})
        (
          lib.filterAttrs
          (_: value: value ? outputs)
          inputs
        );
    in
      nixRegistry;

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    settings.extra-sandbox-paths = ["/bin/sh=${pkgs.bash}/bin/sh"];

    gc = {
      automatic = lib.mkDefault true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = 536870912
    '';
  };

  environment = {
    systemPackages = with pkgs; [
      # core system utils
      binutils
      coreutils

      # extra utils
      bat
      bottom
      btop
      curl
      du-dust
      fd
      file
      git
      htop
      jq
      less
      neovim
      pciutils
      ripgrep
      tree
      usbutils

      # network utils
      dnsutils
      nmap
      whois
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
  };

  # extra programs
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function bonk
        nix shell ${builtins.toString ../../.}#$argv
      end
    '';
  };
  users.defaultUserShell = pkgs.fish;
  programs.command-not-found.enable = false;

  # disable manually creating users
  users.mutableUsers = false;

  boot.cleanTmpDir = true;

  # time
  time.timeZone = "America/Toronto";
  services.timesyncd.enable = true;
}
