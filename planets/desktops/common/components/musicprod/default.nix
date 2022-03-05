{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # DAW
    ss.lmms

    # extras
    carla
    yabridge
    yabridgectl

    # Plugins
    bespokesynth
    tunefish
    geonkick
    padthv1
    aeolus
    helm
    zyn-fusion
    yoshimi
    drumkv1
    bristol
    ChowKick
    sorcer
    surge-XT
    samplv1
    industrializer
    infamousPlugins
    distrho
    x42-plugins
    aether-lv2
    mooSpace
    drumgizmo
    vocproc
    talentedhack
  ];

  home.sessionVariables = {
    DSSI_PATH = "$HOME/.dssi:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/dssi:/run/current-system/sw/lib/dssi";
    LADSPA_PATH = "$HOME/.ladspa:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/ladspa:/run/current-system/sw/lib/ladspa";
    LV2_PATH = "$HOME/.lv2:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/lv2:/run/current-system/sw/lib/lv2";
    LXVST_PATH = "$HOME/.lxvst:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/lxvst:/run/current-system/sw/lib/lxvst";
    VST_PATH = "$HOME/.vst:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/vst:/run/current-system/sw/lib/vst";
    VST3_PATH = "$HOME/.vst3:/nix/var/nix/profiles/per-user/woze/home-manager/home-path/lib/vst3:/run/current-system/sw/lib/vst3";
  };
}
