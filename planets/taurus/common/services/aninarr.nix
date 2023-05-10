{
  pkgs,
  inputs,
  ...
}: {
  systemd.services = {
    "aninarr" = {
      description = "aninarr daemon";

      path = with pkgs; [bash];
      serviceConfig = {
        ExecStart = "${pkgs.aninarr.aninarr}/bin/aninarr";
        WorkingDirectory = "/mnt/pstore1/datas/aninarr";
        Restart = "always";
        RestartSec = "5s";
        User = "root";
        Group = "root";
      };

      after = ["network.target"];
      wantedBy = ["multi-user.target"];
    };
    "aninarrh" = {
      description = "aninarrh daemon";

      serviceConfig = {
        ExecStart = "${pkgs.aninarr.aninarrh}/bin/aninarrh localhost 5071";
        WorkingDirectory = "${pkgs.aninarr.aninarrh}";
        StandardOutput = "inherit";
        StandardError = "inherit";
        Restart = "always";
        RestartSec = "5s";
      };

      after = ["aninarr.service"];
      wantedBy = ["multi-user.target"];
    };
    "aninarrx" = {
      description = "aninarrx daemon";

      path = with pkgs; [bash jq];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash helper.bash localhost yes";
        WorkingDirectory = "${pkgs.aninarr.aninarrx}";
        Restart = "always";
        RestartSec = "5s";
      };

      after = ["aninarr.service"];
      wantedBy = ["multi-user.target"];
    };
  };
}
