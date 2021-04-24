({ lib, newScope, stdenv, pkgs }:
  let

    # nicer aliases
    derive = stdenv.mkDerivation;
    concat = builtins.concatStringsSep " ";

    # vendored libuvc: don't build, just make sources available
    libuvc-src = derive {
      name = "libuvc-src";
      # using fetchgit instead fetchFromGitHub because
      # the .git directory is needed by arcan's cmake scripts
      src = pkgs.fetchgit {
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

  in
  lib.makeScope newScope (self: with self; let

    mkArcanAppl = { name, src, applRoot }: callPackage
      ({ pkgs }: derive {
        name = name;
        src = src;
        nativeBuildInputs = with pkgs; [ envsubst ];
        buildInputs = [ arcan ];
        installPhase = ''
          mkdir -p $out/${name} $out/bin
          cp -r ./${applRoot}/* $out/${name}/
          Arcan=${arcan} Appls=$out Appl=${name} envsubst \
            < ${./Arcan.wrapper} \
            > $out/bin/arcan.${name}
          chmod +x $out/bin/arcan.${name}
        '';
      })
      { };

    arcanRev = "15633f5ee718f05c2f360fe95cbff31a5c50fa0b";

    arcanCoreSrc = pkgs.fetchgit {
      leaveDotGit = true;
      url = "https://github.com/letoram/arcan.git";
      rev = arcanRev;
      sha256 = "0pzgb8s74na9wr8dy3bgvv23fry2zny4w6kzjyq1q5lnsgma0zqn";
    };

  in
  {

    # arcan core:

    arcan = callPackage
      ({ pkgs }: derive {
        name = "arcan";
        src = arcanCoreSrc;
        patches = [ ./Arcan.nosuid.patch ]; # nix refuses to build suid binaries
        postUnpack = '' # add vendored libuvc
      mkdir -p ./arcan/external/git/libuvc
      pushd ./arcan/external/git/
      shopt -s dotglob nullglob  # bashism: * now also matches dotfiles
      cp -r ${libuvc-src}/* libuvc/
      shopt -u dotglob nullglob  # phases are stateful
      popd
    '';
        nativeBuildInputs = with pkgs; [ cmake gcc git ];
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
        PKG_CONFIG_PATH = concat [
          # make wayland protocols available
          "${pkgs.wayland-protocols}/share/pkgconfig"
          "${pkgs.libusb1.dev}/lib/pkgconfig"
        ];
        CFLAGS = concat [
          # don't warn on read()/write() without a format
          "-Wno-format" # (Arcan code uses them on SHMIFs)
          "-Wno-format-security"
        ];
        cmakeFlags = concat (
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
      ({ pkgs }: derive {
        name = "acfgfs";
        src = arcanCoreSrc;
        nativeBuildInputs = with pkgs; [ cmake gcc git ];
        buildInputs = [ arcan ] ++ (with pkgs; [ fuse3 ]);
        cmakeFlags = concat ((arcanIncludeDirs arcan) ++ [ "../src/tools/acfgfs" ]);
      })
      { };

    aclip = callPackage
      ({ pkgs }: derive {
        name = "aclip";
        src = arcanCoreSrc;
        nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
        buildInputs = [ arcan ];
        PKG_CONFIG_PATH = concat [ "${arcan}/lib/pkgconfig" ];
        cmakeFlags = concat ((arcanIncludeDirs arcan) ++ [ "../src/tools/aclip" ]);
      })
      { };

    aloadimage = callPackage
      ({ pkgs }: derive {
        name = "aloadimage";
        src = arcanCoreSrc;
        nativeBuildInputs = with pkgs; [ cmake gcc git ];
        buildInputs = [ arcan ];
        cmakeFlags = concat ((arcanIncludeDirs arcan) ++ [ "../src/tools/aloadimage" ]);
      })
      { };

    shmmon = callPackage
      ({ pkgs }: derive {
        name = "shmmon";
        src = arcanCoreSrc;
        nativeBuildInputs = with pkgs; [ cmake gcc git ];
        buildInputs = [ arcan ];
        cmakeFlags = concat ((arcanIncludeDirs arcan) ++ [ "../src/tools/shmmon" ]);
      })
      { };

    # TODO: provide <hidapi/hidapi.h> include path
    #vrbridge = callPackage ({ pkgs }: derive {
    #name = "vrbridge";
    #src = ./arcan;
    #nativeBuildInputs = with pkgs; [ cmake gcc git pkg-config ];
    #buildInputs = [ arcan ] ++ (with pkgs; [ libusb1 ]);
    #cmakeFlags = concat (
    #(arcanIncludeDirs arcan) ++
    #(libusbDirs pkgs.libusb1) ++
    #[ "../src/tools/vrbridge" ]
    #);
    #}) {};

    # arcan appls

    awb = mkArcanAppl {
      name = "awb";
      src = pkgs.fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/awb.git";
        rev = "271ef7ffd7f24569d2f836198e4c96b8c617e372";
        sha256 = "1jdmiinsd91nnli5hgcn9c6ifj0s6ngbyjwm0z6fim4f8krnh0s8";
      };
      applRoot = "";
    };

    prio = mkArcanAppl {
      name = "prio";
      src = pkgs.fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/prio.git";
        rev = "c3f97491339d15f063d6937d5f89bcfaea774dd1";
        sha256 = "0igsbzp0df24f856sfwzcgcfanxlvxmw5v94gqq2p42kwardfmm9";
      };
      applRoot = "";
    };

    durden = mkArcanAppl {
      name = "durden";
      src = pkgs.fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/durden.git";
        rev = "bfbfe68bc325a5fb06ea1869a99404e277291a89";
        sha256 = "11zfd1cf0sh63a9wrm5n129jmb5m0ibfh51ryjjjgxgx901k2qhi";
      };
      applRoot = "durden";
    };

    safespaces = mkArcanAppl {
      name = "safespaces";
      src = pkgs.fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/safespaces.git";
        rev = "58eef59afba091293cab4d2b156e725f75d92eaf";
        sha256 = "1jdmiinsd91nnli5hgcn9c6ifj0s6ngbyjwm0z6fim4f8krnh0s9";
      };
      applRoot = "safespaces";
    };

    pipeworld = mkArcanAppl {
      name = "pipeworld";
      src = pkgs.fetchgit {
        leaveDotGit = true;
        url = "https://github.com/letoram/pipeworld.git";
        rev = "6bf0a0f8d0250866910ea59f6d0a9ecdf4bd0013";
        sha256 = "1jdmiinsd91nnli5hgcn9c6ifj0s6ngbyjwm0z6fim4f8krnh0s9";
      };
      applRoot = "pipeworld";
    };
  }))
