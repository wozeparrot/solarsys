{ stdenv
, boost
, coreutils
, cppzmq
, curl
, libepoxy
, fetchFromGitHub
, glib
, glm
, gtkmm3
, lib
, libarchive
, libgit2
, librsvg
, libuuid
, opencascade
, pkg-config
, podofo
, python3
, sqlite
, wrapGAppsHook
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "horizon-eda";
  version = "3d834e6ea63cbaa15799f06b683f96f32967d31f";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = version;
    sha256 = "sha256-wMz5+tQy7i/Cc3iHDS0HwvK6hIqyOup+zkNPcr3AJbY=";
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
    maintainers = with maintainers; [ guserav ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}