{ lib
, stdenv
, fetchFromGitHub
, nodePackages
}:

stdenv.mkDerivation rec {
  pname = "goosemod-openasar";
  version = "d7d372e068001d10f573540e4872ef0c538ebd23";

  src = fetchFromGitHub {
    owner = "GooseMod";
    repo = "OpenAsar";
    rev = version;
    sha256 = "sha256-K0xV4gM/dEqPZAltskZ8KBiZamf9YsO9gxXu5ltwhPE=";
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

