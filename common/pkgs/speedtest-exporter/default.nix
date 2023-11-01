{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "speedtest-exporter";
  version = "unstable-2023-06-14";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = pname;
    rev = "15a770da971a5ac3dc1d7aa99ce90fbea82d7251";
    sha256 = "sha256-pojavVdIK3/8eBzfrXrqRBxYevFO3DPfA9NY4rPmyw0=";
  };

  vendorHash = "sha256-PrTIfoTSEB9vs8e75p+u4qoDimf1mj4OzVXZhJoj8G8=";
}
