{ pkgs ? import <nixpkgs> { } }:
let
  unlockedNix = pkgs.writeShellScriptBin "nix" ''
    ${pkgs.nixFlakes}/bin/nix --option experimental-features "nix-command flakes ca-references" "$@"
  '';

  solarsys-build = pkgs.writeShellScriptBin "solarsys-build" ''
    host=''${host:-"$(${pkgs.hostname}/bin/hostname)"}

    path=.#nixosConfigurations."$host".config.system.build.toplevel
    
    echo Building "$host" 1>&2
    
    ${unlockedNix}/bin/nix build "$@" "$path" 1>&2
    ${unlockedNix}/bin/nix path-info "$@" "$path"
  '';

  solarsys-switch = pkgs.writeShellScriptBin "solarsys-switch" ''
    host=''${host:-"$(${pkgs.hostname}/bin/hostname)"}

    sudo nixos-rebuild --flake ".#$host" switch
  '';

  solarsys-rollback = pkgs.writeShellScriptBin "solarsys-rollback" ''
    host=''${host:-"$(${pkgs.hostname}/bin/hostname)"}

    sudo nixos-rebuild --flake ".#$host" switch --rollback
  '';

  solarsys-test = pkgs.writeShellScriptBin "solarsys-test" ''
    host=''${host:-"$(${pkgs.hostname}/bin/hostname)"}

    sudo nixos-rebuild --flake ".#$host" test
  '';

  solarsys-update = pkgs.writeShellScriptBin "solarsys-update" ''
    ${unlockedNix}/bin/nix flake update

    git diff
    read

    git commit -am "update flakes"
  '';
in
pkgs.mkShell {
  name = "solarsys";
  nativeBuildInputs = with pkgs; [
    git
    unlockedNix

    solarsys-build
    solarsys-switch
    solarsys-rollback
    solarsys-test
    solarsys-update
  ];

  shellHook = ''
    PATH=${unlockedNix}/bin:$PATH
  '';
}
