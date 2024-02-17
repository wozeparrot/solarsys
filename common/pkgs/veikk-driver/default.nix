# WARNING: if you want to install this driver for the Veikk, make sure to either run it as root (to avoid issues with udev rules)
# or (to get udev rule loaded) to add it in `services.udev.packages. For now, all models seems to use the same file, but in case of doubt double check here
# https://www.veikk.com/support/download.html
# Make sure to run a single instance.
{ stdenv, lib, fetchzip, dpkg, libusb, autoPatchelfHook, libGL, glib, fontconfig, libXi, libX11, dbus, makeWrapper, xkeyboard_config }:
stdenv.mkDerivation {
  name = "veikk-driver";
  version = "";

  # This is like 20M, so it can take some time
  src = fetchzip {
    url = "https://veikk.com/image/catalog/Software/new/vktablet-1.2.4-10-x86_64.zip";
    sha256 = "sha256-r37och6BZRYp6yCtyhY/vbBD2XQIYCURpaMyJIcS4mw=";
  };

  buildInputs = [ dpkg libusb autoPatchelfHook libGL stdenv.cc.cc.lib glib libX11 libXi dbus fontconfig makeWrapper xkeyboard_config];

  unpackPhase = ''
    echo "Unpacking";
    dpkg -x $src/*.deb .
  '';

  installPhase = ''
    mkdir -p $out
    mv usr/lib $out/opt # contains the main executable
    mv usr/share $out/share # Contains the desktop file
    mv lib $out/lib # Contains udev rules
    substituteInPlace $out/share/applications/vktablet.desktop \
      --replace "Exec=/usr/lib/vktablet/vktablet" "Exec=$out/opt/vktablet/vktablet" \
      --replace "Icon=/usr/lib/vktablet/vktablet.png" "Icon=$out/opt/vktablet/vktablet.png"
    makeWrapper $out/opt/vktablet/vktablet $out/bin/vktablet \
      --set QT_XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb
  '';
}
