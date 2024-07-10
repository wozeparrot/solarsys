{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # DAW
    reaper

    # extras
    carla
    yabridge
    yabridgectl

    # Plugins
    infamousPlugins # TODO: broken
    CHOWTapeModel
    ChowKick
    LibreArp-lv2
    aeolus
    aether-lv2
    airwindows-lv2
    artyFX
    bespokesynth
    boops
    bristol
    calf
    cardinal
    delayarchitect
    distrho
    dragonfly-reverb
    drumgizmo
    drumkv1
    faustPhysicalModeling
    fluidsynth
    geonkick
    gxmatcheq-lv2
    gxplugins-lv2
    helm
    industrializer
    lsp-plugins
    magnetophonDSP.CharacterCompressor
    magnetophonDSP.CompBus
    magnetophonDSP.LazyLimiter
    magnetophonDSP.MBdistortion
    magnetophonDSP.RhythmDelay
    # magnetophonDSP.VoiceOfFaust # TODO: broken
    magnetophonDSP.faustCompressors
    magnetophonDSP.shelfMultiBand
    mda_lv2
    mooSpace
    noise-repellent
    padthv1
    quadrafuzz
    rkrlv2
    samplv1
    sorcer
    surge-XT
    swh_lv2
    talentedhack
    tunefish
    vocproc
    x42-gmsynth
    x42-plugins
    yoshimi
    zam-plugins
    zyn-fusion
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
