# modified from: https://github.com/egasimus/nur-packages/blob/master/c/arcan/default.nix

{ lib, newScope, stdenv, fetchgit, pkgs }:

let
  # vendored libuvc: don't build, just make sources available
  libuvc-src = stdenv.mkDerivation {
    name = "libuvc-src";
    # using fetchgit instead fetchFromGitHub because
    # the .git directory is needed by arcan's cmake scripts
    src = fetchgit {
      leaveDotGit = true;
      url = "https://github.com/letoram/libuvc.git";
      rev = "v0.0.6";
      sha256 = "1jdmiinsd91nnli5hgcn9c6ifj0s6ngbyjwm0z6fim4f8krnh0sf";
    };
    nativeBuildInputs = with pkgs; [ git ];
    # fetchgit strips all refs, leaving just a fetchgit branch
    # but cmake needs to check out the ref called 'master':
    installPhase = ''
      git tag master
      cp -r . $out/
      cd $out
    '';
  };

  # cmake flags pointing to locations of arcan headers
  arcanIncludeDirs = arcan: [
    "-DARCAN_SHMIF_INCLUDE_DIR=${arcan}/include/arcan/shmif"
    "-DARCAN_TUI_INCLUDE_DIR=${arcan}/include/arcan"
  ];

  # cmake flags pointing to locations of libusb1 headers and binaries
  libusbDirs = libusb1: [
    "-DLIBUSB_1_INCLUDE_DIRS=${libusb1.dev}/include/libusb-1.0"
    "-DLIBUSB_1_LIBRARIES=${libusb1}/lib/libusb-1.0.so"
  ];

  # cmake flags pointing to location of hidapi headers and binaries
  hidapiDirs = hidapi: [
    "-DHIDAPI_INCLUDE_DIRS=${hidapi.dev}/include/hidapi"
    "-DHIDAPI_LIBRARIES=${hidapi}/lib/hidapi"
  ];
in
lib.makeScope newScope (self: with self; let
  arcanRev = "0.6.0.1";

  arcanCoreSrc = fetchgit {
    leaveDotGit = true;
    url = "https://github.com/letoram/arcan.git";
    rev = arcanRev;
    sha256 = "1hfqj39klbnh47lv1lbfs4l12kl58l5xkmdmzdc5fi4yg8h56njs";
  };
in
{
  # arcan core:
  arcan = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "arcan";
      src = arcanCoreSrc;
      postUnpack = '' # add vendored libuvc
      mkdir -p ./arcan/external/git/libuvc
      pushd ./arcan/external/git/
      shopt -s dotglob nullglob  # bashism: * now also matches dotfiles
      cp -r ${libuvc-src}/* libuvc/
      shopt -u dotglob nullglob  # phases are stateful
      popd
    '';
      patchPhase = '' # thanks @ChrisOboe!
      sed -i "s,SETUID,,g" ./src/CMakeLists.txt
      substituteInPlace ./src/platform/posix/paths.c \
        --replace "/usr/bin" "$out/bin" \
        --replace "/usr/share" "$out/share"
    '';
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = with pkgs; [
        apr
        espeak-classic
        file
        ffmpeg-full
        freetype
        harfbuzzFull
        leptonica
        libGL
        libdrm
        libjpeg
        libusb1
        libvncserver
        libxkbcommon
        luajit
        lzma
        mesa
        openal
        SDL2
        sqlite
        tesseract
        vlc
        wayland
        wayland-protocols
        xorg.libxcb
        xorg.xcbutil
        xorg.xcbutilwm
      ];
      PKG_CONFIG_PATH = builtins.concatStringsSep " " [
        # make wayland protocols available
        "${pkgs.wayland-protocols}/share/pkgconfig"
        "${pkgs.libusb1.dev}/lib/pkgconfig"
      ];
      CFLAGS = builtins.concatStringsSep " " [
        # don't warn on read()/write() without a format
        "-Wno-format" # (Arcan code uses them on SHMIFs)
        "-Wno-format-security"
      ];
      cmakeFlags = builtins.concatStringsSep " " (
        # cmake won't be able to find these paths on its own:
        (libusbDirs pkgs.libusb) ++ [
          "-DDRM_INCLUDE_DIR=${pkgs.libdrm.dev}/include/libdrm"
          "-DGBM_INCLUDE_DIR=${pkgs.libGL.dev}/include"
          "-DWAYLANDPROTOCOLS_PATH=${pkgs.wayland-protocols}/share/wayland-protocols"
          # enable features:
          "-DVIDEO_PLATFORM=egl-dri"
          "-DSHMIF_TUI_ACCEL=ON"
          "-DENABLE_LWA=ON"
          "-DNO_BUILTIN_OPENHMD=ON"
          "-DHYBRID_SDL=On"
          "-DHYBRID_HEADLESS=On"
          "-DFSRV_DECODE_UVC=Off"
          # optional
          "-DVERBOSE=ON"
          #"--debug-output"
          #"--trace"
          "../src"
        ]
      );
    })
    { };

  # arcan utilities:
  acfgfs = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "acfgfs";
      src = arcanCoreSrc;
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = [ arcan ] ++ (with pkgs; [ fuse3 ]);
      cmakeFlags = builtins.concatStringsSep " " ((arcanIncludeDirs arcan) ++ [ "../src/tools/acfgfs" ]);
    })
    { };

  aclip = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "aclip";
      src = arcanCoreSrc;
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = [ arcan ];
      PKG_CONFIG_PATH = builtins.concatStringsSep " " [ "${arcan}/lib/pkgconfig" ];
      cmakeFlags = builtins.concatStringsSep " " ((arcanIncludeDirs arcan) ++ [ "../src/tools/aclip" ]);
    })
    { };

  aloadimage = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "aloadimage";
      src = arcanCoreSrc;
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = [ arcan ];
      cmakeFlags = builtins.concatStringsSep " " ((arcanIncludeDirs arcan) ++ [ "../src/tools/aloadimage" ]);
    })
    { };

  shmmon = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "shmmon";
      src = arcanCoreSrc;
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = [ arcan ];
      cmakeFlags = builtins.concatStringsSep " " ((arcanIncludeDirs arcan) ++ [ "../src/tools/shmmon" ]);
    })
    { };

  vrbridge = callPackage
    ({ pkgs }: stdenv.mkDerivation {
      name = "vrbridge";
      src = ./arcan;
      nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
      buildInputs = [ arcan ] ++ (with pkgs; [ libusb1 hidapi ]);
      cmakeFlags = builtins.concatStringsSep " " (
        (arcanIncludeDirs arcan) ++
        (libusbDirs pkgs.libusb1) ++
        (hidapiDirs pkgs.hidapi) ++
        [ "../src/tools/vrbridge" ]
      );
    })
    { };
} // (
  let
    mkArcanAppl = { name, src, applRoot }: callPackage
      (
        { bash
        , pkg-config
        }: stdenv.mkDerivation {
          name = name;
          src = src;
          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ arcan ];
          installPhase = ''

        mkdir -p $out/bin $out/share/${name} $out/share/wayland-sessions

        # add appl code
        cp -r ./${applRoot}/* $out/share/${name}/

        # create executable wrapper
        echo -e "#!${bash}/bin/bash\nexec /run/wrappers/bin/arcan $out/share/${name}" \
          > $out/bin/${name}
        chmod +x $out/bin/${name}

        # create session wrapper
        echo -e "[Desktop Entry]\nName=${name} on Arcan ${arcanRev}\nComment=Next Generation Window Manager\nExec=$out/bin/${name}\nType=Application" \
          > $out/share/wayland-sessions/${name}.desktop
        chmod +x $out/share/wayland-sessions/${name}.desktop

      '';
          passthru.providedSessions = [ name ];
        }
      )
      { };
  in
  {
    # arcan appls
    awb = mkArcanAppl {
      name = "awb";
      src = fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/awb.git";
        rev = "271ef7ffd7f24569d2f836198e4c96b8c617e372";
        sha256 = "0g6g493ygabhwfknjlp2rg14iq7njsgh5qll01p2g1i9qvwbbhvq";
      };
      applRoot = "";
    };

    prio = mkArcanAppl {
      name = "prio";
      src = fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/prio.git";
        rev = "c3f97491339d15f063d6937d5f89bcfaea774dd1";
        sha256 = "0igsbzp0df24f856sfwzcgcfanxlvxmw5v94gqq2p42kwardfmm9";
      };
      applRoot = "";
    };

    durden = mkArcanAppl {
      name = "durden";
      src = fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/durden.git";
        rev = "bfbfe68bc325a5fb06ea1869a99404e277291a89";
        sha256 = "0d5g161xaccq3jxci9vwr2xn51ilrcdh3a9sdlsw3d64a1f4x4rv";
      };
      applRoot = "durden";
    };

    safespaces = mkArcanAppl {
      name = "safespaces";
      src = fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/safespaces.git";
        rev = "58eef59afba091293cab4d2b156e725f75d92eaf";
        sha256 = "1jdmiinsd91nnli5hgcn9c6ifj0s6ngbyjwm0z6fim4f8krnh0s9";
      };
      applRoot = "safespaces";
    };
  }
))
