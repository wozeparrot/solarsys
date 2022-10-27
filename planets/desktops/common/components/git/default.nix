{pkgs, ...}: {
  home.packages = with pkgs; [gh];

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
      lola = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)' --all";
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

      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPL+OWmcGo4IlL+LUz9uEgOH8hk0JIN3DXEV8sdgxPB wozeparrot";
      gpg.ssh.allowedSignersFile = "~/.local/share/git_allowed_signers";

      init.defaultBranch = "main";
    };
  };
}
