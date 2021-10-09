{ pkgs, config, inputs, lib, ... }: {
  imports = [
    ./base.nix
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  sdImage.compressImage = false;
  sdImage.firmwareSize = 128;
  sdImage.firmwarePartitionName = "NIXOS_BOOT";
  sdImage.populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  '';

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      ripgrep = prev.rustPlatform.buildRustPackage rec {
        pname = "ripgrep";
        version = "13.0.0";

        src = prev.fetchFromGitHub {
          owner = "BurntSushi";
          repo = pname;
          rev = version;
          sha256 = "0pdcjzfi0fclbzmmf701fdizb95iw427vy3m1svy6gdn2zwj3ldr";
        };

        cargoSha256 = "1kfdgh8dra4jxgcdb0lln5wwrimz0dpp33bq3h7jgs8ngaq2a9wp";

        cargoBuildFlags = "--features pcre2";

        nativeBuildInputs = with prev; [ installShellFiles pkg-config ];
        buildInputs = with prev; [ pcre2 ];

        preFixup = ''
          installManPage $releaseDir/build/ripgrep-*/out/rg.1
          installShellCompletion $releaseDir/build/ripgrep-*/out/rg.{bash,fish}
          installShellCompletion --zsh complete/_rg
        '';

        doCheck = false;

        doInstallCheck = true;
        installCheckPhase = ''
          file="$(mktemp)"
          echo "abc\nbcd\ncde" > "$file"
          $out/bin/rg -N 'bcd' "$file"
          $out/bin/rg -N 'cd' "$file"

          echo '(a(aa)aa)' | $out/bin/rg -P '\((a*|(?R))*\)'
        '';
      };
      pango = prev.pango.overrideAttrs (oldAttrs: {
        outputs = [ "bin" "out" "dev" ];
        mesonFlags = [ "-Dintrospection=disabled" "-Dgtk_doc=false" ];
        postInstall = "";
      });
    })
  ];
}
