{
  stdenv,
  python2,
  fetchurl,
  pam,
}: let
  outPath = placeholder "out";
in
  stdenv.mkDerivation {
    pname = "pam-python";
    version = "1.0.8";

    src = fetchurl {
      url = "https://downloads.sourceforge.net/project/pam-python/pam-python-1.0.8-1/pam-python-1.0.8.tar.gz";
      sha256 = "sha256-/GnXcX2wUJERUAqBBTSH+naE4b47fQritRlwtv3JGPY=";
    };

    buildInputs = [python2 pam];

    preBuild = ''
      patchShebangs .
      substituteInPlace src/Makefile --replace '-Werror' '-O -Werror=cpp'
    '';

    buildPhase = ''
      runHook preBuild

      make lib

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      PREFIX="${outPath}" LIBDIR="${outPath}/lib/security" make install-lib

      runHook postInstall
    '';
  }
