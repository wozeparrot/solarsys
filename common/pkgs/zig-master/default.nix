{ lib
, stdenv
, fetchFromGitHub
, cmake
, llvmPackages_12
, libxml2
, zlib
}:

llvmPackages_12.stdenv.mkDerivation rec {
  pname = "zig";
  commit = "1c636e2564e2fc2e8e4b6b1edbc782592ee3d2d7";

  src = fetchFromGitHub {
    owner = "ziglang";
    repo = pname;
    rev = commit;
    hash = "sha256-rZYv8LFH3M70SyPwPVyul+Um9j82K8GZIepVmaonzPw=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    libxml2
    zlib
  ] ++ (with llvmPackages_12; [
    clang-unwrapped
    lld
    llvm
  ]);

  preBuild = ''
    export HOME=$TMPDIR;
  '';

  checkPhase = ''
    runHook preCheck
    ./zig test --cache-dir "$TMPDIR" -I $src/test $src/test/stage1/behavior.zig
    runHook postCheck
  '';

  doCheck = false;
}

