{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nix = {
    package = pkgs.nixVersions.latest;
    settings.system-features = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];

    registry =
      let
        nixRegistry = {
          nixpkgs = {
            flake = inputs.nixpkgs;
          };
        };
      in
      lib.mkDefault nixRegistry;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # settings.extra-sandbox-paths = ["/bin/sh=${pkgs.bash}/bin/sh"];

    gc = {
      automatic = lib.mkDefault true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    settings = {
      connect-timeout = 5;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      log-lines = 25;
      max-free = 1024 * 1024 * 1024;
      min-free = 128 * 1024 * 1024;
      builders-use-substitutes = true;
    };

    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
  };

  environment = {
    systemPackages = with pkgs; [
      # core system utils
      binutils
      coreutils

      # extra utils
      bat
      btop
      curl
      dust
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
  };
  users.defaultUserShell = pkgs.fish;
  programs.command-not-found.enable = false;

  # disable manually creating users
  users.mutableUsers = false;

  # clean tmp on boot
  boot.tmp.cleanOnBoot = true;

  # networking
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  # time
  services.timesyncd.enable = lib.mkDefault true;
}
