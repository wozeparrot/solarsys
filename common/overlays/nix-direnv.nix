self: super: {
  xclip = self.nix-direnv.override { enableFlakes = true; };
}
