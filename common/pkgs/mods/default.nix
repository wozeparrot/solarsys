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
    hash = "";
  };

  vendorHash = "";

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
