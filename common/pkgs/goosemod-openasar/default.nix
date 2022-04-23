{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "e256e8fea1c14570a4aa665ca3295fffb8d71cd9";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-KL8UoT50GWyvmxTQlN8UzViuBplfKGeQ6pTDAFdss90=";
  };

  nativeBuildInputs = [
    nodePackages.asar
  ];

  buildInputs = [
    unzip
  ];

  patchPhase =
    let
      unzipBin = "${unzip}/bin/unzip";
    in
    ''
      rm -rf src/node_modules
      mkdir src/node_modules
      cp -rf poly/* src/node_modules
      sed -i -e "s/nightly/nightly-${builtins.substring 0 7 version}/" src/index.js
      sed -i -e "s/unzip/${lib.strings.escape ["/"] unzipBin}/" src/updater/moduleUpdater.js
    '';

  installPhase = ''
    mkdir -p $out
    asar pack src $out/app.asar
  '';
}

