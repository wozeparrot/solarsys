{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkg-config,
  vulkan-loader,
  ninja,
  writeText,
  vulkan-headers,
  vulkan-utility-libraries,
  jq,
  libX11,
  libXrandr,
  libxcb,
  wayland,
  wayland-scanner,
}:
stdenv.mkDerivation {
  pname = "vulkan-hdr-layer";
  version = "unstable-2024-12-27";

  src = fetchFromGitHub {
    owner = "Zamundaaa";
    repo = "VK_hdr_layer";
    rev = "1534ef826bfecf525a6c3154f2e3b52d640a79cf";
    fetchSubmodules = true;
    hash = "sha256-LaI7axY+O6MQ/7xdGlTO3ljydFAvqqdZpUI7A+B2Ilo=";
  };

  nativeBuildInputs = [
    vulkan-headers
    meson
    ninja
    pkg-config
    jq
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    vulkan-utility-libraries
    libX11
    libXrandr
    libxcb
    wayland
    wayland-scanner
  ];

  # Help vulkan-loader find the validation layers
  setupHook = writeText "setup-hook" ''
    addToSearchPath XDG_DATA_DIRS @out@/share
  '';

  meta = with lib; {
    description = "Layers providing Vulkan HDR";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
