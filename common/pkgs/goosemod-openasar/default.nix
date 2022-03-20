{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "399727845b347346b8e6bcfb5d703c7ebdefcb4e";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-a7oPT2EUDVkx1TPBEHibiHZfYGU/OVbROmiivsh3h1U=";
  };

  nativeBuildInputs = [
    nodePackages.asar
  ];

  buildInputs = [
    unzip
  ];

  patchPhase = ''
    rm -rf src/node_modules
    mkdir src/node_modules
    cp -rf poly/* src/node_modules
    cp ${./yauzl.js} src/node_modules/yauzl.js
    sed -i -e "s/nightly/nightly-${builtins.substring 0 7 version}/" src/index.js
  '';

  installPhase = ''
    mkdir -p $out
    asar pack src $out/app.asar
  '';
}

