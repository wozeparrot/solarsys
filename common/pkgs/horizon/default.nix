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
  version = "unstable-2024-11-20";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = "3a1697f6d6abe80c3179bdd2d0bf82c4aef722d6";
    sha256 = "sha256-MEFTYPYy2Teajo1UirbMmh5W584ZpyQ5V3EJxfoVRVg=";
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
