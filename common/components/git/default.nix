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

    extraConfig = {
      github.user = "wozeparrot@gmail.com";

      pull.rebase = true;

      diff.colorMoved = "default";

      difftool.prompt = false;
      "difftool \"nvim\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

      mergetool.prompt = true;
      "mergetool \"nvim-merge\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

      core = editor = "nvim";
    };
  };
}
