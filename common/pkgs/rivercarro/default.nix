{ lib
, stdenv
, fetchgit
, git
, zig
, wayland
, pkg-config
, river
, scdoc
, xwayland
, wayland-protocols
, wlroots
, libxkbcommon
, pixman
, udev
, libevdev
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "rivercarro";
  version = "a4b925083497d5321300d64f9f5ef3a1afd91a56";

  src = fetchgit {
    url = "https://git.sr.ht/~novakane/rivercarro";
    rev = version;
    sha256 = lib.fakeSha256;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ git zig wayland xwayland scdoc pkg-config river ];

  buildInputs = [
    wayland-protocols
    wlroots
    pixman
    libxkbcommon
    pixman
    udev
    libevdev
    libX11
    libGL
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline --prefix $out install
    runHook postInstall
  '';

  /*
    Builder patch install dir into river to get default config
    When installFlags is removed, river becomes half broken.
    See https://github.com/ifreund/river/blob/7ffa2f4b9e7abf7d152134f555373c2b63ccfc1d/river/main.zig#L56
  */
  installFlags = [ "DESTDIR=$(out)" ];
}
