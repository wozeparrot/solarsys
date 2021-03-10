{ pkgs
, lib
, fetchFromGitHub
, autoreconfHook
, pkgconfig
, libxkbcommon
, pango
, which
, git
, cairo
, libxcb
, xcbutil
, xcbutilwm
, xcbutilxrm
, libstartup_notification
, bison
, flex
, librsvg
, check
}:

pkgs.stdenv.mkDerivation rec {
  name = "rofi";
  commit = "60eb00ce1b52aee46d343481d0530d5013ab850b";

  src = fetchFromGitHub {
    owner = "davatorium";
    repo = "rofi";
    rev = commit;
    sha256 = "0nzacjwfjh1vl0a66yv84q6zai08iagjj6ca0zzz4xzfw59m36qc";
    fetchSubmodules = true;
  };

  preConfigure = ''
    patchShebangs "script"
    # root not present in build /etc/passwd
    sed -i 's/~root/~nobody/g' test/helper-expand.c
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [
    libxkbcommon
    pango
    cairo
    git
    bison
    flex
    librsvg
    check
    libstartup_notification
    libxcb
    xcbutil
    xcbutilwm
    xcbutilxrm
    which
  ];

  doCheck = false;
}
