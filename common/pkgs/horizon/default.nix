{
  stdenv,
  boost,
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
  opencascade,
  pkg-config,
  podofo,
  python3,
  sqlite,
  wrapGAppsHook,
  zeromq,
}:
stdenv.mkDerivation rec {
  pname = "horizon-eda";
  version = "2.3.90";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = "v${version}";
    sha256 = "sha256-fF0T5UUG/I2zK4HwN6JFG1AuuNxZ7yJQXQ9s+iHGjDw=";
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
    opencascade
    podofo
    python3
    sqlite
    zeromq
  ];

  nativeBuildInputs = [
    boost.dev
    pkg-config
    wrapGAppsHook
  ];

  CASROOT = opencascade;

  installFlags = [
    "INSTALL=${coreutils}/bin/install"
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A free EDA software to develop printed circuit boards";
    homepage = "https://horizon-eda.org";
    maintainers = with maintainers; [guserav];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
