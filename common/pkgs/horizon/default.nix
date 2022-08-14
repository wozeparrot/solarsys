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
, libspnav
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
  version = "unstable-2022-08-13";

  src = fetchFromGitHub {
    owner = "horizon-eda";
    repo = "horizon";
    rev = "e9de49915208335e65839049b9eb13c996cd57fe";
    sha256 = "sha256-DL0CMqQrqb4skyjTjFUVuv9U/OY7FaMd037U9ZKMxHg=";
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
    maintainers = with maintainers; [ guserav ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
