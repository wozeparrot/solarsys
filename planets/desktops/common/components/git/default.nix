{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    userEmail = "wozeparrot@gmail.com";
    userName = "Woze Parrot";

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      last = "log -1 HEAD";
      cane = "commit --amend --no-edit";
      d = "diff";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      a = "add";
      pl = "pull";
      ps = "push";
    };

    lfs.enable = true;

    delta = {
      enable = true;
      options.features = "decorations side-by-side line-numbers";
    };

    extraConfig = {
      github.user = "wozeparrot@gmail.com";

      pull.rebase = true;

      diff.colorMoved = "default";

      difftool.prompt = false;
      "difftool \"nvim\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

      mergetool.prompt = true;
      "mergetool \"nvim-merge\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

      core.editor = "nvim";

      #gpg.format = "ssh";
      #user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot";
      #gpg.ssh.allowedSignersFile = "~/.local/share/git_allowed_signers";
    };
  };
  xdg.dataFile.git_allowed_signers.text = ''
    wozeparrot@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot
  '';

  programs.gh = {
    enable = true;
    enableGitCredentialHelper = false;
  };
}
