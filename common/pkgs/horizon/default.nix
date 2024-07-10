{
  stdenv,
  coreutils,
  cppzmq,
  curl,
  libepoxy,
  fetchFromGitHub,
  glib,
  glm,
  gtkmm3,
  lib,
  libarchive,
  libgit2,
  librsvg,
  libspnav,
  libuuid,
  opencascade-occt,
  pkg-config,
  podofo,
  python3,
  python3Packages,
  sqlite,
  wrapGAppsHook,
  zeromq,
  cmake,
  meson,
  ninja,
}:
stdenv.mkDerivation {
  pname = "horizon-eda";
  version = "unstable-2024-02-11";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = "ddd15df6297900ce22d1480a68604a24fe6e60c2";
    sha256 = "sha256-hKLQ3MWslQLViCpgK9JJskRhIF4CzVxLcrgrDWrbW+Q=";
  };

  buildInputs = [
    cppzmq
    curl
    libepoxy
    glib.dev
    glm
    gtkmm3
    libarchive
    libgit2
    librsvg
    libspnav
    libuuid
    opencascade-occt
    podofo
    python3
    python3Packages.pycairo
    sqlite
    zeromq
    cmake
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
    meson
    ninja
  ];

  CASROOT = opencascade-occt;

  installFlags = [
    "INSTALL=${coreutils}/bin/install"
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A free EDA software to develop printed circuit boards";
    homepage = "https://horizon-eda.org";
    maintainers = with maintainers; [ guserav ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
