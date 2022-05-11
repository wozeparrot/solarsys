{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "c9c3b5ecff67d66af3b77ccb404a9a76cef90bc5";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-+RAf8mFrSgfebGLc679Fwdc62qpH0Cf5ka7H/Ogopiw=";
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

