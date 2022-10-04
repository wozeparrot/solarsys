{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  cmake,
  expat,
  freetype,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  pop-launcher,
  wayland,
}:
rustPlatform.buildRustPackage rec {
  pname = "onagre";
  version = "9764271963825045cff30fcee3fb1953290fcefb";

  src = fetchFromGitHub {
    owner = "oknozor";
    repo = "onagre";
    rev = version;
    sha256 = "sha256-bdRJ+xSWmhWn0WTFvw3+wy1AjR6ScleMsnWN1H/gvEs=";
  };

  doCheck = false;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    makeWrapper
    pkg-config
  ];
  buildInputs = [
    freetype
    expat
    wayland
    libxkbcommon
    pop-launcher
  ];

  postInstall = ''
    wrapProgram $out/bin/onagre \
      --suffix LD_LIBRARY_PATH : ${wayland}/lib/:${libxkbcommon}/lib
  '';

  cargoHash = "sha256-CevPvydJg6TV4+XoN/VX0NgS2KmVWYWnf2G1CSZqZ+M=";
}
