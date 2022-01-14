{ lib
, stdenv
, fetchgit
, zig
, river
, wayland
, pkg-config
, scdoc
}:

stdenv.mkDerivation rec {
  pname = "rivercarro";
  version = "0.1.2";

  src = fetchgit {
    url = "https://git.sr.ht/~novakane/rivercarro";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-53CIbSGcWId5pZ0qdMOfO0s/qOdvI04MsdSDOM9ArR4=";
  };

  nativeBuildInputs = [
    pkg-config
    river
    scdoc
    wayland
    zig
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline -Dman-pages --prefix $out install
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~novakane/rivercarro";
    description = "A layout generator for river Wayland compositor, fork of rivertile";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ kraem ];
  };
}

