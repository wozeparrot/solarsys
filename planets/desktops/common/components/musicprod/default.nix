{pkgs, ...}: {
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
    gxplugins-lv2
    swh_lv2
    mda_lv2
    gxmatcheq-lv2
    rkrlv2
    boops
    artyFX
    zam-plugins
    faustPhysicalModeling
    CHOWTapeModel
    lsp-plugins
    calf
    dragonfly-reverb
    quadrafuzz
    magnetophonDSP.VoiceOfFaust
  ];

  home.sessionVariables = {
    DSSI_PATH = "$HOME/.dssi:/etc/profiles/per-user/woze/lib/dssi:/run/current-system/sw/lib/dssi";
    LADSPA_PATH = "$HOME/.ladspa:/etc/profiles/per-user/woze/lib/ladspa:/run/current-system/sw/lib/ladspa";
    LV2_PATH = "$HOME/.lv2:/etc/profiles/per-user/woze/lib/lv2:/run/current-system/sw/lib/lv2";
    LXVST_PATH = "$HOME/.lxvst:/etc/profiles/per-user/woze/lib/lxvst:/run/current-system/sw/lib/lxvst";
    VST_PATH = "$HOME/.vst:/etc/profiles/per-user/woze/lib/vst:/run/current-system/sw/lib/vst";
    VST3_PATH = "$HOME/.vst3:/etc/profiles/per-user/woze/lib/vst3:/run/current-system/sw/lib/vst3";
  };
}
