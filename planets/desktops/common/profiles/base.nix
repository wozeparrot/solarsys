{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../../../common/profiles/base.nix
    ./user.nix
  ];

  nix = {
    registry =
      let
        nixRegistry = builtins.mapAttrs (_: v: { flake = v; }) (
          lib.filterAttrs (_: value: value ? outputs) inputs
        );
      in
      nixRegistry;

    gc.automatic = false;
  };

  # nix cross build support
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.extraOptions = ''
    extra-platforms = aarch64-linux i686-linux
  '';

  boot.initrd.systemd.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment.homeBinInPath = true;

  # extra programs
  programs.firejail.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      SDL
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_ttf
      SDL_image
      SDL_mixer
      SDL_ttf
      acl
      alsa-lib
      atk
      attr
      bzip2
      cairo
      coreutils
      cups
      curl
      dbus
      dbus-glib
      e2fsprogs
      expat
      ffmpeg
      flac
      fontconfig
      freeglut
      freetype
      fuse
      gdk-pixbuf
      glew110
      glib
      gnome2.GConf
      gsettings-desktop-schemas
      gtk2
      gtk3
      icu
      libGL
      libappindicator-gtk2
      libcaca
      libcanberra
      libcap
      libdbusmenu-gtk2
      libdrm
      libelf
      libgbm
      libgcrypt
      libidn
      libindicator-gtk2
      libjpeg
      libmikmod
      libnotify
      libogg
      libpng
      libpng12
      librsvg
      libsamplerate
      libsodium
      libssh
      libtheora
      libtiff
      libudev0-shim
      libusb1
      libva
      libvdpau
      libvorbis
      libvpx
      libxcrypt
      libxkbcommon
      libxml2
      networkmanager
      nspr
      nss
      openssl
      pango
      pciutils
      pipewire
      pixman
      speex
      stdenv.cc.cc
      systemd
      tbb
      util-linux
      vulkan-loader
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXft
      xorg.libXi
      xorg.libXinerama
      xorg.libXmu
      xorg.libXrandr
      xorg.libXrender
      xorg.libXt
      xorg.libXtst
      xorg.libXxf86vm
      xorg.libxcb
      xorg.libxshmfence
      xz
      zenity
      zlib
      zstd
    ];
  };

  programs.fish.interactiveShellInit = ''
    function bonk
      nix shell ${builtins.toString ../../../../.}#$argv
    end
  '';

  programs.fuse.userAllowOther = true;

  # services
  ## oom killer
  services.earlyoom = {
    enable = true;
    enableNotifications = false;
  };
  services.udisks2.enable = true;
  services.envfs.enable = true;
  services.dbus.implementation = "broker";

  # rtkit
  security.rtkit.enable = true;
}
