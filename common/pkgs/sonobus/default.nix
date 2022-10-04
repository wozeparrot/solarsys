{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libjack2,
  libopus,
  opusTools,
  xorg,
  alsa-lib,
  libGL,
  freetype,
  curl,
}:
stdenv.mkDerivation rec {
  pname = "sonobus";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "sonosaurus";
    repo = pname;
    rev = version;
    sha256 = "sha256-W92aj+noVfN9sxL14Gcm2LzbAZK1HY6DXOmLwzx8P3I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libjack2
    libopus
    opusTools
    alsa-lib
    xorg.libX11
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXcursor
    libGL
    freetype
    curl
  ];
}
