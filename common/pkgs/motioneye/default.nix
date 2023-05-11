{
  fetchFromGitHub,
  curl,
  ffmpeg,
  lib,
  lsb-release,
  motion,
  python3Packages,
  which,
}: let
  bins = [ffmpeg lsb-release motion which];
in
  python3Packages.buildPythonApplication rec {
    pname = "motioneye";
    version = "unstable-2023-04-07";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "ccrisan";
      repo = pname;
      rev = "ef1c42b57895324a2fb7129e63d37412061a82e2";
      sha256 = "sha256-SkkSOPb3lLJ5e9fr6ac+9HMbCpJXC9TZdDrreeBdi4c=";
    };

    buildInputs = bins;

    postPatch = ''
      substituteInPlace motioneye/scripts/relayevent.sh \
        --replace curl ${curl}/bin/curl
    '';

    postInstall = ''
      mv $out/${python3Packages.python.sitePackages}/motioneye/scripts/*.sh $out/bin
      rmdir $out/${python3Packages.python.sitePackages}/motioneye/scripts
    '';

    makeWrapperArgs = [
      "--prefix PATH : ${lib.makeBinPath bins}"
    ];

    propagatedBuildInputs = with python3Packages; [jinja2 pillow pycurl boto3 tornado];

    doCheck = false;
  }
