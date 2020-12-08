{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, uthash
, asciidoc
, docbook_xml_dtd_45
, docbook_xsl
, libxslt
, libxml2
, makeWrapper
, meson
, ninja
, xorgproto
, libxcb
, xcbutilrenderutil
, xcbutilimage
, pixman
, libev
, dbus
, libconfig
, libdrm
, libGL
, pcre
, libX11
, libXinerama
, libXext
, xwininfo
, libxdg_basedir
}:

stdenv.mkDerivation rec {
  pname = "picom";
  commit = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";

  src = fetchFromGitHub {
    owner = "ibhagwan";
    repo = "picom";
    rev = commit;
    sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    uthash
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    makeWrapper
  ];

  buildInputs = [
    dbus
    libX11
    libXext
    xorgproto
    libXinerama
    libdrm
    pcre
    libxml2
    libxslt
    libconfig
    libGL
    libxcb
    xcbutilrenderutil
    xcbutilimage
    pixman
    libev
    libxdg_basedir
  ];

  NIX_CFLAGS_COMPILE = "-fno-strict-aliasing";

  mesonFlags = [
    "-Dbuild_docs=true"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/picom-trans \
      --prefix PATH : ${lib.makeBinPath [ xwininfo ]}
  '';
}
