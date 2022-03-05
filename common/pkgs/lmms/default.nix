{ lib
, fetchFromGitHub
, cmake
, qttools
, pkg-config
, perl
, perlPackages
, alsa-lib
, fftwFloat
, fltk13
, fluidsynth
, lame
, libgig
, libjack2
, libpulseaudio
, libsamplerate
, libsndfile
, libsoundio
, libvorbis
, portaudio
, sndio
, qtbase
, qtx11extras
, lv2
, lilv
, suil
, flac
, carla
, SDL2
, xorg
, wine64
, mkDerivation
}:

mkDerivation rec {
  pname = "lmms";
  version = "3c67510bbf5b900d77112a800900c7bd6fd18721";

  src = fetchFromGitHub {
    owner = "wozeparrot";
    repo = pname;
    rev = version;
    sha256 = "sha256-6Blddb3Pwrwm/opbom+7wVnURZJJCwbYoDKWNJ4HE0M=";
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

  cmakeFlags = [ "-DWANT_SOUNDIO=OFF" ];
}
