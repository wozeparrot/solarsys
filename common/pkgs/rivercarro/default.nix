{
  lib,
  stdenv,
  fetchgit,
  zig,
  river,
  wayland,
  pkg-config,
  scdoc,
}:
stdenv.mkDerivation rec {
  pname = "rivercarro";
  version = "unstable-2022-05-04";

  src = fetchgit {
    url = "https://git.sr.ht/~novakane/rivercarro";
    rev = "44994be37f6e50188060dfeee41cae9f3f688e83";
    fetchSubmodules = true;
    sha256 = "sha256-+RFnV0JbDXurDQnGIW3mKFRyL5ar5bNznWjTTxOmrkg=";
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
  };
}
