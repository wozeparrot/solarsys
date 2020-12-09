{ stdenv, fetchFromGitHub, cmake, jdk8, zlib, file, makeWrapper, xorg, libpulseaudio, qtbase }:
let
  jdk = jdk8;
  libpath = with xorg; stdenv.lib.makeLibraryPath [ libX11 libXext libXcursor libXrandr libXxf86vm libpulseaudio ];
in
stdenv.mkDerivation rec {
  name = "multimc";
  commit = "8a0027c73a755849bf5b58c1509c71a543ddb982";
  src = fetchFromGitHub {
    owner = "MultiMC";
    repo = "MultiMC5";
    rev = commit;
    sha256 = "1llfx77mx2y23lx31brg33rd5bagny9pwmpyd7r446fymhil4ixl";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [ cmake file makeWrapper ];
  buildInputs = [ qtbase jdk zlib ];

  enableParallelBuilding = true;

  cmakeFlags = [ "-DMultiMC_LAYOUT=lin-system" ];

  postInstall = ''
    install -Dm644 ../application/resources/multimc/scalable/multimc.svg $out/share/pixmaps/multimc.svg
    install -Dm755 ../application/package/linux/multimc.desktop $out/share/applications/multimc.desktop

    # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
    wrapProgram $out/bin/multimc --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} --prefix PATH : ${jdk}/bin/:${xorg.xrandr}/bin/
  '';

  meta = with stdenv.lib; {
    homepage = "https://multimc.org/";
    description = "A free, open source launcher for Minecraft";
    longDescription = ''
      Allows you to have multiple, separate instances of Minecraft (each with their own mods, texture packs, saves, etc) and helps you manage them and their associated options with a simple interface.
    '';
    platforms = platforms.linux;
    license = licenses.lgpl21Plus;
    maintainers = [ maintainers.cleverca22 ];
  };
}
