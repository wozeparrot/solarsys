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
    rev = "4378fe232c240975b2c5b5115440b4a8afdfd501";
    sha256 = "sha256-jAOzhL0fs7sI5vtyqRGum4hsCXit4jPqJxnW1fopEPU=";
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
