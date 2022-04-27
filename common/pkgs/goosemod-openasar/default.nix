{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "d5d55b54caf5b719e7ae789c36c0114c4b42c909";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-od5rNTDaP3aD62G5nEvcAe+8K/ShBa/JbPwkx2SxcoE=";
  };

  nativeBuildInputs = [
    nodePackages.asar
  ];

  propagatedBuildInputs = [
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
      sed -i -e 's/proc\.stderr\.on.*//' src/updater/moduleUpdater.js
    '';

  installPhase = ''
    mkdir -p $out
    asar pack src $out/app.asar
  '';
}

