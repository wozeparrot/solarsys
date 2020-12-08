{ stdenv
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

stdenv.mkDerivation rec {
  pname = "rofi";
  commit = "57ee69367d1ffe01c6e5ebb9b2fa5cb83060639f";

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
