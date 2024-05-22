{ lib
, buildGoModule
, fetchFromGitHub
, gitUpdater
, testers
, mods
}:

buildGoModule rec {
  pname = "mods";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    rev = "v${version}";
    hash = "sha256-9sr6R7Keg9NQQapZKnjfrMOJilQEYCs8AS04TuNWQ68=";
  };

  vendorHash = "sha256-BL5bxyeVkcm7GO1Kzk9d/hj2wY50UhauEFq9YQ/JbCE=";

  ldflags = [ "-s" "-w" "-X=main.Version=${version}" ];

  doCheck = false;

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
      ignoredVersions = ".(rc|beta).*";
    };

    tests.version = testers.testVersion {
      package = mods;
      command = "HOME=$(mktemp -d) mods -v";
    };
  };
}
