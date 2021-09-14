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
  version = "unstable-2021-09-14";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = pname;
    rev = "5f6428bafe41da2c5df6c6cb12ff65c225260322";
    sha256 = "sha256-LdBMbPTz0fGXz5yHtOEpUdfmZt+ouWg4g2q1k/qawBI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig wayland xwayland scdoc pkg-config ];

  buildInputs = [
    wayland-protocols
    wlroots
    pixman
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
    zig build -Drelease-safe=true -Dcpu=baseline -Dxwayland -Dman-pages --prefix $out install
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
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}

