{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, unzip
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "b0dd7d01a0dc4f0633475ff13ea0d14e90d23d01";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-m10KsB6SRgspKbHlRTer1ALN3kvE1Yjo6+lbYS0t7aQ=";
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

