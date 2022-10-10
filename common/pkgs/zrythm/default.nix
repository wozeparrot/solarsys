{
  stdenv,
  lib,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  bash,
  bash-completion,
  breeze-icons,
  carla,
  chromaprint,
  cmake,
  curl,
  dconf,
  fftw,
  fftwFloat,
  flex,
  glib,
  graphviz,
  gtk4,
  gtksourceview5,
  guile,
  help2man,
  jq,
  json-glib,
  libadwaita,
  libaudec,
  libbacktrace,
  libcyaml,
  libepoxy,
  libgtop,
  libjack2,
  libpanel,
  libpulseaudio,
  libsamplerate,
  libsndfile,
  libsoundio,
  libxml2,
  libyaml,
  lilv,
  lv2,
  meson,
  ninja,
  pandoc,
  pcre,
  pcre2,
  pkg-config,
  python3,
  reproc,
  rtaudio,
  rtmidi,
  rubberband,
  sassc,
  serd,
  sord,
  sratom,
  texi2html,
  vamp-plugin-sdk,
  wrapGAppsHook,
  xdg-utils,
  xxHash,
  zstd,
}:
stdenv.mkDerivation rec {
  pname = "zrythm";
  version = "1.0.0-beta.3.6.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-+YPaWe/Tu29DPtsFLCi5c18nlL12DxR4md/TDWZ6ekE=";
  };

  nativeBuildInputs = [
    cmake
    help2man
    jq
    libaudec
    libxml2
    meson
    ninja
    pandoc
    pkg-config
    python3
    python3.pkgs.sphinx
    texi2html
    wrapGAppsHook
  ];

  buildInputs = [
    SDL2
    alsa-lib
    bash-completion
    breeze-icons
    carla
    chromaprint
    curl
    dconf
    fftw
    fftwFloat
    flex
    glib
    graphviz
    gtk4
    gtksourceview5
    guile
    json-glib
    libadwaita
    libbacktrace
    libcyaml
    libepoxy
    libgtop
    libjack2
    libpanel
    libpulseaudio
    libsamplerate
    libsndfile
    libsoundio
    libyaml
    lilv
    lv2
    pcre
    pcre2
    reproc
    rtaudio
    rtmidi
    rubberband
    sassc
    serd
    sord
    sratom
    vamp-plugin-sdk
    xdg-utils
    xxHash
    zstd
  ];

  mesonFlags = [
    "-Drtmidi=enabled"
    "-Drtaudio=enabled"
    "-Dsdl=enabled"
    "-Dcarla=enabled"
    "-Dmanpage=true"
    # "-Duser_manual=true" # needs sphinx-intl
    "-Dlsp_dsp=disabled"
    "-Db_lto=false"
    "-Ddebug=true"
    "-Dopus=true"
  ];

  NIX_LDFLAGS = ''
    -lfftw3_threads -lfftw3f_threads
  '';

  dontStrip = true;

  postPatch = ''
    chmod +x scripts/meson-post-install.sh
    patchShebangs ext/sh-manpage-completions/run.sh scripts/generic_guile_wrap.sh \
      scripts/meson-post-install.sh tools/check_have_unlimited_memlock.sh
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GSETTINGS_SCHEMA_DIR : "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/"
             )
  '';

  meta = with lib; {
    homepage = "https://www.zrythm.org";
    description = "Highly automated and intuitive digital audio workstation";
    platforms = platforms.linux;
    license = licenses.agpl3Plus;
  };
}
