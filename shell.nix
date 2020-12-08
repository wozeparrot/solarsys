{ pkgs ? import <nixpkgs> { } }:
let
  solarsys-build = pkgs.writeStrictShellScriptBin "solarsys-build" ''
    host=''${host:-"$(${pkgs.hostname}/bin/hostname)"}

    path=.#nixosConfigurations."$host".config.system.build.toplevel
    
    echo Building "$host" 1>&2
    
    ${pkgs.nixUnstable}/bin/nix build "$@" "$path" 1>&2
    ${pkgs.nixUnstable}/bin/nix path-info "$@" "$path"
  '';

  solarsys-update = pkgs.writeStrictShellScriptBin "solarsys-update" ''
    for pkg in $(${pkgs.jq}/bin/jq -r '.nodes | keys[] | select(. != "root")' flake.lock); do
      ${pkgs.nixUnstable}/bin/nix flake update --update-input "$pkg" "$@"
    done
  '';
in
  pkgs.mkShell {
    name = "solarsys";
    nativeBuildInputs = with pkgs; [
      git
      nixUnstable

      solarsys-build
      solarsys-update
    ];

    shellHook = ''
      PATH=${
        pkgs.writeShellScriptBin "nix" ''
          ${pkgs.nixUnstable}/bin/nix --option experimental-features "nix-command flakes ca-references" "$@"
        ''
      }/bin:$PATH
    '';
  }
