{ stdenv, lib, fetchFromGitLab, rustPlatform, }:

rustPlatform.buildRustPackage rec {
  pname = "matrix-conduit";
  version = "fb2a7ebf66cd358b391eb6c25524fccf35f138dd";

  src = fetchFromGitLab {
    owner = "famedly";
    repo = "conduit";
    rev = version;
    sha256 = "sha256-C10W75MNZdkaJDlXqYoEejI0UvOvswqVaZqvn4xZUxU=";
  };

  cargoSha256 = "sha256-zyzgxNBUO+xR/kL3CQHI3gCE0wS7H//ujUvCtrs69tc=";

  buildNoDefaultFeatures = true;
  buildFeatures = [ "conduit_bin" "backend_sqlite" ];

  meta = with lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs/";
    license = licenses.asl20;
  };
}
