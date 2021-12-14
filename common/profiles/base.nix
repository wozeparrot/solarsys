{ config, pkgs, inputs, lib, ... }:
{
  nix = {
    package = pkgs.nixUnstable;
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

    registry =
      let
        nixRegistry = builtins.mapAttrs (name: v: { flake = v; })
          (
            lib.filterAttrs
              (name: value: value ? outputs)
              inputs
          );
      in
      nixRegistry;

    nixPath = [ "nixpkgs=${inputs.unstable}" ];
    sandboxPaths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];

    gc = {
      automatic = true;
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
      coreutils
      binutils

      # extra utils
      ripgrep
      htop
      curl
      file
      tree
      less
      git
      neovim
      pciutils
      usbutils
      du-dust
      nix-index
      fd
      jq

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
  };

  # extra programs
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  programs.command-not-found.enable = false;

  # disable manually creating users
  users.mutableUsers = false;

  # time
  time.timeZone = "America/Toronto";
  services.timesyncd.enable = true;
}
