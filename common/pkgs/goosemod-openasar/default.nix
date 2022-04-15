{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "2a82ee5a1c7e986c371de89c429b29f0673529a2";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-hBPvlPN7BkpQWCSdbG3ZS64QbQAodEcThbe30T8YFZo=";
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

