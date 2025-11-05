{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git-branchless
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user = {
          name = "Woze Parrot";
          email = "wozeparrot@gmail.com";
        };

        alias = {
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

        github.user = "wozeparrot@gmail.com";

        merge.conflictstyle = "zdiff3";

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

        rerere.enabled = true;

        diff.algorithm = "histogram";

        status.submoduleSummary = true;
        diff.submodule = "log";
        submodule.recurse = true;

        push.autoSetupRemote = true;
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    gitui = {
      enable = true;
    };

    difftastic = {
      enable = true;
      git.enable = true;
      options.background = "dark";
    };
  };
}
