{ lib
, buildPythonPackage
, fetchFromGitHub
, ffmpeg
, rtmpdump
, phantomjs2
, atomicparsley
, pycryptodomex
, websockets
, mutagen
, ffmpegSupport ? true
, rtmpSupport ? true
, phantomjsSupport ? false
, hlsEncryptedSupport ? true
, withAlias ? false # Provides bin/youtube-dl for backcompat
}:

buildPythonPackage rec {
  pname = "yt-dlp";
  version = "d6bc443bdeb8d0246cef1c4b8b9206a18413dbca";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = pname;
    rev = version;
    sha256 = "sha256-0NfJsM+gC9dkabop5pwUwVllAAyPYPRv6yMHwe7NuCM=";
  };

  propagatedBuildInputs = [ websockets mutagen ]
    ++ lib.optional hlsEncryptedSupport pycryptodomex;

  # Ensure these utilities are available in $PATH:
  # - ffmpeg: post-processing & transcoding support
  # - rtmpdump: download files over RTMP
  # - atomicparsley: embedding thumbnails
  makeWrapperArgs =
    let
      packagesToBinPath = [ atomicparsley ]
        ++ lib.optional ffmpegSupport ffmpeg
        ++ lib.optional rtmpSupport rtmpdump
        ++ lib.optional phantomjsSupport phantomjs2;
    in
    [ ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"'' ];

  setupPyBuildFlags = [
    "build_lazy_extractors"
  ];

  # Requires network
  doCheck = false;

  postInstall = lib.optionalString withAlias ''
    ln -s "$out/bin/yt-dlp" "$out/bin/youtube-dl"
  '';
}

