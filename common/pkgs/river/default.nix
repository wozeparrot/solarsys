{ lib
, stdenv
, fetchFromGitHub
, zig
, wayland
, pkg-config
, scdoc
, xwayland
, wayland-protocols
, wlroots
, libxkbcommon
, pixman
, udev
, libevdev
, libinput
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "river";
  version = "79d7775a3de55d618dc8d9d137e75f6afa2e589c";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = version;
    sha256 = "sha256-Z6C6py8t96Lk5hKgyR26H5hdbyjwEozukZykXcEk3/w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig wayland xwayland scdoc pkg-config ];

  buildInputs = [
    wayland-protocols
    wlroots
    libxkbcommon
    pixman
    udev
    libevdev
    libinput
    libX11
    libGL
  ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Drelease-safe -Dcpu=baseline -Dxwayland -Dman-pages --prefix $out install
    runHook postInstall
  '';

  /*
    Builder patch install dir into river to get default config
    When installFlags is removed, river becomes half broken.
    See https://github.com/ifreund/river/blob/7ffa2f4b9e7abf7d152134f555373c2b63ccfc1d/river/main.zig#L56
  */
  installFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/ifreund/river";
    description = "A dynamic tiling wayland compositor";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}

