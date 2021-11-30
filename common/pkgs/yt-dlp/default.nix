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
  version = "717216b0930c742dab5bbd065e9c58caace74a8c";

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = pname;
    rev = version;
    sha256 = "sha256-ICKj2749op55G0dbI0idZElIosJ+cbcis1FDk5yAVJY=";
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

