{
  config,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  undmg,

  alsa-lib,
  curl,
  ffmpeg_4-headless,
  glibc,
  gtk3,
  lame,
  libjack2,
  libx11,
  libxml2_13,
  openssl,
  udev,
  vlc,
  which,
  xdg-utils,
  xdotool,

  jackSupport ? stdenv.hostPlatform.isLinux,
  jackLibrary ? libjack2, # Another option is "pipewire.jack"
  pulseaudioSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  libpulseaudio,
}:

let
  url_for_platform =
    version: arch:
    if stdenv.hostPlatform.isDarwin then
      "https://www.reaper.fm/files/${lib.versions.major version}.x/reaper${
        builtins.replaceStrings [ "." ] [ "" ] version
      }_universal.dmg"
    else
      "https://www.reaper.fm/files/${lib.versions.major version}.x/reaper${
        builtins.replaceStrings [ "." ] [ "" ] version
      }_linux_${arch}.tar.xz";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "reaper";
  version = "7.73";

  src = fetchurl {
    url = url_for_platform finalAttrs.version stdenv.hostPlatform.qemuArch;
    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-iEslm5gmkkCwCfwilgXgRrwpj6D6lNypDZnNIv1ZPKw="
      else
        {
          x86_64-linux = "sha256-tXyflaxx00SCqjo7xZFOigMwAc0i/i3Jakwr6BuasbQ=";
          aarch64-linux = "sha256-+fbpuu0iAqEnchKwkct/FmooE0cpBUkSUyI3HCT+Nwg=";
        }
        .${stdenv.hostPlatform.system};
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    which
    autoPatchelfHook
    xdg-utils # Required for install script
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  sourceRoot = lib.optionalString stdenv.hostPlatform.isDarwin "Reaper.app";

  buildInputs = [
    (lib.getLib stdenv.cc.cc) # reaper and libSwell need libstdc++.so.6
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    alsa-lib
  ];

  runtimeDependencies =
    lib.optionals stdenv.hostPlatform.isLinux [
      gtk3 # libSwell needs libgdk-3.so.0
    ]
    ++ lib.optional jackSupport jackLibrary
    ++ lib.optional pulseaudioSupport libpulseaudio;

  dontBuild = true;
  dontStrip = true;

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall
        mkdir -p "$out/Applications/Reaper.app"
        cp -r * "$out/Applications/Reaper.app/"
        makeWrapper "$out/Applications/Reaper.app/Contents/MacOS/REAPER" "$out/bin/reaper"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        HOME="$out/share" XDG_DATA_HOME="$out/share" ./install-reaper.sh \
          --install $out/opt \
          --integrate-user-desktop
        rm $out/opt/REAPER/uninstall-reaper.sh

        # Dynamic loading of plugin dependencies does not adhere to rpath of
        # reaper executable that gets modified with runtimeDependencies.
        # Patching each plugin with DT_NEEDED is cumbersome and requires
        # hardcoding of API versions of each dependency.
        # Setting the rpath of the plugin shared object files does not
        # seem to have an effect for some plugins.
        # We opt for wrapping the executable with LD_LIBRARY_PATH prefix.
        # Note that libcurl and libxml2_13 are needed for ReaPack to run.
        wrapProgram $out/opt/REAPER/reaper \
          --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              curl
              ffmpeg_4-headless
              glibc
              lame
              libx11
              libxml2_13
              openssl
              stdenv.cc.cc
              udev
              vlc
              xdotool
            ]
          }"

        mkdir $out/bin
        ln -s $out/opt/REAPER/reaper $out/bin/

        # Avoid store path in Exec, since we already link to $out/bin
        substituteInPlace $out/share/applications/cockos-reaper.desktop \
          --replace-fail "Exec=\"$out/opt/REAPER/reaper\"" "Exec=reaper"

        runHook postInstall
      '';
})
