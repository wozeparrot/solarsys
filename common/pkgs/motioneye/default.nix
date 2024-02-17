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
    version = "unstable-2024-02-15";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "motioneye-project";
      repo = pname;
      rev = "2675cd20ab1df365d0efce204051296f23033c1c";
      sha256 = "sha256-0YWFDDDzkdxTBpiM0vVv80gW+nUqkb2Pt7Ew/XT5T5I=";
    };

    nativeBuildInputs = [python3Packages.babel];
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

    propagatedBuildInputs = with python3Packages; [jinja2 pillow pycurl boto3 tornado setuptools];

    doCheck = false;
  }
