{ lib
, stdenv
, fetchFromGitHub
, nodePackages
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "82037247e0c5e9509a5b4dc7dbd4894fdbb02697";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-yl0azG2Od6KOf4y2aLOQDRFK/79MWU9EVOpXxi2VdCE=";
  };

  nativeBuildInputs = [
    nodePackages.asar
  ];

  patchPhase = ''
    rm -rf src/node_modules
    mkdir src/node_modules
    cp -rf poly/* src/node_modules
    sed -i -e "s/nightly/nightly-${builtins.substring 0 7 version}/" src/index.js
  '';

  installPhase = ''
    mkdir -p $out
    asar pack src $out/app.asar
  '';
}

