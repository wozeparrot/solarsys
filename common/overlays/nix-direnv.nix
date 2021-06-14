self: super: {
  nix-direnv = self.nix-direnv.override { enableFlakes = true; };
}
