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
  version = "c3bf67ec43b80c9b5f797aca694eb8e485c8509f";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = "${version}";
    sha256 = "sha256-+425GVlG+E6RaS7q4Ry51FpE8+/NQNURGgnKJPq/o1g=";
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
