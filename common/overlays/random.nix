final: prev: {
  umr = prev.umr.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "tomstdenis";
      repo = "umr";
      rev = "f257b6f19a088d424563403ff3d7f8d4dc52e085";
      hash = "sha256-ooY0TNmS9yPWMx4wA/yy9yPFfNz02bWtfkeWQe3f/oI=";
    };
  });
}
