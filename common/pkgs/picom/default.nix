{ stdenv
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
  name = "picom";
  commit = "60eb00ce1b52aee46d343481d0530d5013ab850b";

  src = fetchFromGitHub {
    owner = "ibhagwan";
    repo = "picom";
    rev = commit;
    sha256 = "PDQnWB6Gkc/FHNq0L9VX2VBcZAE++jB8NkoLQqH9J9Q=";
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
      --prefix PATH : ${stdenv.lib.makeBinPath [ xwininfo ]}
  '';
}
