{ stdenv
, lib
, fetchFromGitHub

  # Build tools
, cmake
, pkg-config

, lzma
, libuvc
, libffi
, libX11
, libxcb
, libXcomposite
, libXfixes
, xcbutil
, xcbutilwm
, libXau
, libXdmcp
, openal
, freetype
, sqlite
, libGL
, libdrm
, libxkbcommon
, mesa
, valgrind
, luajit
, libusb1
, harfbuzzFull

, SDL2

  # For generating API documentation
, ruby

, withVLC ? true
, libvlc

  #
, withFFmpeg ? true
, ffmpeg-full

  # 
, withWayland ? true
, wayland
, wayland-protocols

  #
, withEspeak ? true
, espeak-classic

  # 
, withLibmagic ? true
, file

  #
, withTesseractAndLeptonica ? true
, tesseract
, leptonica

  #
, withVNC ? true
, libvncserver

  #
, debugBuild ? false
}:

let
  pname = "arcan";

  version = "d703315747fc6ae157842d3f8970b8267971f73b";

  srcs = {
    arcan = fetchFromGitHub {
      owner = "letoram";
      repo = "arcan";
      rev = version;
      sha256 = "1q9lw0y6kwy807lgwhfy2kfns9bdrfhwd1n5wi7sszz3irykqqw8";
    };

    openal = fetchFromGitHub {
      owner = "letoram";
      repo = "openal";
      rev = "1c7302c580964fee9ee9e1d89ff56d24f934bdef"; # master
      sha256 = "0dcxcnqjkyyqdr2yk84mprvkncy5g172kfs6vc4zrkklsbkr8yi2";
    };
  };

  src = srcs.arcan;

  postUnpack = ''
    ln -sv ${srcs.openal} $sourceRoot/external/git/openal

    # Generate manpages
    pushd $sourceRoot/doc/
    mkdir mantmp
    ruby docgen.rb mangen
    popd
  '';

  patches = [
    ./nosuid.patch
  ];

  postPatch = ''
    substituteInPlace ./src/platform/posix/paths.c \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share" "$out/share"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    ruby
  ];

  buildInputs = [
    openal
    freetype
    sqlite
    libuvc
    libGL
    SDL2
    libdrm
    libxkbcommon
    mesa
    valgrind
    luajit
    libusb1
    libvlc
    lzma
    libffi
    libX11
    libxcb
    libXcomposite
    libXfixes
    xcbutil
    xcbutilwm
    libXau
    libXdmcp
    harfbuzzFull
  ] ++ lib.optionals withFFmpeg [
    ffmpeg-full
  ] ++ lib.optionals withWayland [
    wayland
    wayland-protocols
  ] ++ lib.optionals withEspeak [
    espeak-classic
  ] ++ lib.optionals withLibmagic [
    file
  ] ++ lib.optionals withTesseractAndLeptonica [
    tesseract
    leptonica
  ] ++ lib.optionals withVNC [
    libvncserver
  ];

  cmakeFlags = [
    "-DBUILD_PRESET=everything"
    "-DISTR_TAG=Nixpkgs"
    "-DENGINE_BUILDTAG=${version}+Nixpkgs"
    "../src"
  ] ++ lib.optionals debugBuild [
    "-DCMAKE_BUILD_TYPE=Debug"
  ];

  hardeningDisable = [ "format" ];

  meta = {
    lib.description = "Scriptable Multimedia Engine";
    lib.longDescription = ''
      Arcan  is a portable and fast self-sufficient multimedia engine for
      advanced visualization and analysis work in a wide range of applications
      e.g. game development, real-time streaming video,  monitoring  and
      surveillance, up to and including desktop compositors and window managers.
    '';
    lib.homepage = "https://github.com/letoram/arcan";
    lib.changelog = "https://github.com/letoram/arcan/releases/tag/${version}";
    lib.license = with lib.licenses; [ gpl2Plus lgpl2Plus bsd3 ];
    lib.platforms = lib.platforms.linux;
    lib.maintainers = with lib.maintainers; [ a12l ];
  };
in
stdenv.mkDerivation {
  inherit pname version src postUnpack patches postPatch nativeBuildInputs buildInputs cmakeFlags hardeningDisable meta;
}
