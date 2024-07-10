{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "pop-launcher";
  version = "47852e53cb6f637003ed6bdb178fe76cb90dff24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "launcher";
    rev = version;
    sha256 = "sha256-LeKaJIvooD2aUlY113P0mzxOcj63sGkrA0SIccNqCLY=";
  };

  cargoHash = "sha256-iHzM3sUv+D5p7+24WPAFfrOiYJEBiStj6uru+YAldxk=";
  cargoBuildFlags = [ "-p pop-launcher-bin" ];

  # this doesn't actually test anything
  doCheck = false;

  postInstall = ''
    mv $out/bin/pop-launcher-bin $out/bin/pop-launcher

    mkdir -p $out/lib/pop-launcher/plugins

    plugins="calc desktop_entries files find pulse recent terminal web"
    for plugin in $plugins; do
      mkdir -p $out/lib/pop-launcher/plugins/"$plugin"
      install -Dm0644 plugins/src/"$plugin"/*.ron $out/lib/pop-launcher/plugins/"$plugin"
      ln -sf $out/bin/pop-launcher $out/lib/pop-launcher/plugins/"$plugin"/"$(echo "$plugin" | sed 's/_/-/')"
    done
  '';
}
