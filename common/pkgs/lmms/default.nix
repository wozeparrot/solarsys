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
  version = "unstable-2022-05-04";

  src = fetchFromGitHub {
    owner = "wozeparrot";
    repo = pname;
    rev = "a0d00fb3839a2699a47092f767e5f7e494f213d3";
    sha256 = "sha256-0ZNMekHK8hV7Byq5UeshL01nI/cGcvIdiihrUoDM4AQ=";
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
