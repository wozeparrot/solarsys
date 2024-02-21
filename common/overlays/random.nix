final: prev: {
  gpu-screen-recorder = prev.gpu-screen-recorder.overrideAttrs (old: {
    version = "unstable-2024-02-20";

    src = final.fetchurl {
      url = "https://dec05eba.com/snapshot/gpu-screen-recorder.git.r493.d56db4a.tar.gz";
      hash = "sha256-fpLgGdnk9qJ0BO+YCFZp4n539G7we7b7+ts07D4uyac=";
    };

    postInstall = ''
      install -Dt $out/bin gpu-screen-recorder gsr-kms-server
      mkdir $out/bin/.wrapped
      mv $out/bin/gpu-screen-recorder $out/bin/.wrapped/
      makeWrapper "$out/bin/.wrapped/gpu-screen-recorder" "$out/bin/gpu-screen-recorder" \
      --prefix LD_LIBRARY_PATH : ${final.libglvnd}/lib \
      --suffix PATH : $out/bin
    '';
  });
}
