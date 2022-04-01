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
  version = "54bee2272e10af303eaa659f5a76f9119d0ea671";

  src = fetchFromGitHub {
    owner = "wozeparrot";
    repo = pname;
    rev = version;
    sha256 = "sha256-qJeNNJ7+qMzv3af/ul9uBol1Hk9Gcny6EHKqZ7P1k5Q=";
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
