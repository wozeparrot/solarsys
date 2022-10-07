{
  lib,
  fetchFromGitHub,
  cmake,
  qttools,
  pkg-config,
  perl,
  perlPackages,
  alsa-lib,
  fftwFloat,
  fltk13,
  fluidsynth,
  lame,
  libgig,
  libjack2,
  libpulseaudio,
  libsamplerate,
  libsndfile,
  libsoundio,
  libvorbis,
  portaudio,
  sndio,
  qtbase,
  qtx11extras,
  lv2,
  lilv,
  suil,
  flac,
  carla,
  SDL2,
  xorg,
  wine64,
  mkDerivation,
}:
mkDerivation rec {
  pname = "lmms";
  version = "unstable-2022-10-05";

  src = fetchFromGitHub {
    owner = "LMMS";
    repo = pname;
    rev = "a57265cf8dad3c341793e87177620b1531589941";
    sha256 = "sha256-csSPFII+cQGLj7tEF/MMOLI4yBdty1snvFyd7zcN/2M=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    perl
    perlPackages.ListMoreUtils
    perlPackages.XMLParser
  ];

  buildInputs = [
    alsa-lib
    fftwFloat
    fltk13
    fluidsynth
    lame
    libgig
    libjack2
    libpulseaudio
    libsamplerate
    libsndfile
    libsoundio
    libvorbis
    portaudio
    sndio
    qtbase
    qtx11extras
    lv2
    lilv
    suil
    flac
    carla
    SDL2
    xorg.libXdmcp
    wine64
  ];

  postPatch = ''
    patchShebangs ./
  '';

  cmakeFlags = ["-DWANT_SOUNDIO=OFF"];
}
