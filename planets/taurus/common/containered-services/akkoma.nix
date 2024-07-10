{ pkgs, inputs, ... }:
{
  containers.akkoma = {
    autoStart = false;
    # ephemeral = true;

    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];

    additionalCapabilities = [ "CAP_MKNOD" ];

    extraFlags = [ "--bind=/dev/fuse" ];

    config =
      { config, ... }:
      {
        imports = [ "${inputs.patched-akkoma}/nixos/modules/services/web-apps/akkoma.nix" ];

        disabledModules = [ "services/web-apps/akkoma.nix" ];

        nixpkgs.overlays = [
          (self: super: { inherit (inputs.patched-akkoma.legacyPackages."${pkgs.system}") formats; })
        ];

        # mount seaweedfs
        systemd.services."seaweedfs-mount" = {
          description = "mount seaweedfs for/in container";

          path = with pkgs; [ fuse3 ];

          serviceConfig = {
            ExecStart = "${pkgs.seaweedfs.seaweedfs}/bin/weed mount -dir /var/lib/akkoma -filer.path /services/akkoma -filer=10.11.235.1:9302";
            ExecStartPost = "${pkgs.coreutils}/bin/sleep 10";
            Restart = "on-failure";
            RestartSec = "10s";
          };

          after = [ "network.target" ];
          before = [
            "akkoma.target"
            "postgresql.target"
          ];
          wantedBy = [
            "multi-user.target"
            "akkoma-config.target"
            "akkoma-initdb.target"
            "akkoma.target"
            "postgresql.target"
          ];
        };

        # configure postgresql
        services.postgresql = {
          enable = true;
          dataDir = "/var/lib/akkoma/db/";
          settings = {
            max_connections = 20;
            shared_buffers = "256MB";
            effective_cache_size = "768MB";
            maintenance_work_mem = "64MB";
            checkpoint_completion_target = 0.9;
            wal_buffers = "7864kB";
            default_statistics_target = 100;
            random_page_cost = 4;
            effective_io_concurrency = 2;
            work_mem = "6553kB";
            min_wal_size = "1GB";
            max_wal_size = "4GB";
          };
        };
        systemd.services."postgresql" = {
          after = [ "seaweedfs-mount.service" ];
        };

        services.akkoma = {
          enable = true;
          extraStatic = {
            "emoji/blobs.gg" = pkgs.akkoma-emoji.blobs_gg;
            "static/terms-of-service.html" = pkgs.writeText "terms-of-service.html" ''
              <h1>Terms of Service</h1>
              <p>Basically don't spam, don't hate, and don't be illegal.</p>
              <p>Also mark NSFW content as such.</p>
              <br/>
              <p>For more information, see <a href="https://enqy.one/policy">enqy.one/policy</a>.</p>
            '';
          };
          dist.address = "127.0.0.1";
          dist.erlAddress = "{127, 0, 0, 1}";
          config = {
            ":pleroma" = {
              ":instance" = {
                name = "enqoma";
                email = "contact@enqy.one";
                description = "enqy's akkoma instance.";
                upload_dir = "/var/lib/akkoma/uploads";
                limit = 10000;
                description_limit = 1000;
                remote_limit = 10000;
                upload_limit = 64000000;
                avatar_upload_limit = 16000000;
                background_upload_limit = 16000000;
                banner_upload_limit = 16000000;
                registrations_open = false;
                invites_enabled = true;
                account_activation_required = false;
                account_approval_required = false;
                public = true;
              };
              "Pleroma.Repo" = {
                adapter = (pkgs.formats.elixirConf { }).lib.mkRaw "Ecto.Adapters.Postgres";
                socket_dir = "/run/postgresql";
                username = "akkoma";
                database = "akkoma";
                prepare = ":named";
                parameters = ''[ plan_cache_mode: "force_custom_plan" ]'';
                connect_timeout = 15000;
              };
              ":mrf" = {
                policies = [
                  "Pleroma.Web.ActivityPub.MRF.SimplePolicy"
                  "Pleroma.Web.ActivityPub.MRF.HashtagPolicy"
                  "Pleroma.Web.ActivityPub.MRF.TagPolicy"
                  "Pleroma.Web.ActivityPub.MRF.ObjectAgePolicy"
                ];
                transparency = true;
              };
              ":mrf_simple" = {
                reject = [
                  [
                    "ignorelist.com"
                    "sus"
                  ]
                  [
                    "mastodong.lol"
                    "malicious sus"
                  ]
                  [
                    "activitypub-troll.cf"
                    "malicious sus"
                  ]
                  [
                    "misskey-forkbomb.cf"
                    "malicious sus"
                  ]
                  [
                    "repl.co"
                    "malicious sus"
                  ]
                ];
              };
              ":mrf_hashtag" = {
                sensitive = [ "nsfw" ];
              };
              ":mrf_object_age" = {
                threshold = 604800;
                actions = [
                  ":delist"
                  ":strip_followers"
                ];
              };
              "Pleroma.Web.Endpoint" = {
                url = {
                  scheme = "https";
                  host = "ak.enqy.one";
                  port = 443;
                };
                http = {
                  ip = "{127, 0, 0, 1}";
                  port = 7320;
                };
                signing_salt = {
                  _secret = "/var/lib/akkoma/secrets/signing-salt";
                };
                secret_key_base = {
                  _secret = "/var/lib/akkoma/secrets/key-base";
                };
                live_view.signing_salt = {
                  _secret = "/var/lib/akkoma/secrets/liveview-salt";
                };
              };
              "Pleroma.Captcha" = {
                enabled = false;
              };
              "Pleroma.Upload" = {
                filters = [
                  "Pleroma.Upload.Filter.Exiftool"
                  "Pleroma.Upload.Filter.Dedupe"
                  "Pleroma.Upload.Filter.AnonymizeFilename"
                  "Pleroma.Upload.Filter.AnalyzeMetadata"
                ];
                link_name = true;
              };
              "Pleroma.Web.Metadata" = {
                unfurl_nsfw = true;
              };
            };
            ":web_push_encryption" = {
              ":vapid_details" = {
                public_key = {
                  _secret = "/var/lib/akkoma/secrets/vapid-public";
                };
                private_key = {
                  _secret = "/var/lib/akkoma/secrets/vapid-private";
                };
              };
            };
            ":joken" = {
              ":default_signer" = {
                _secret = "/var/lib/akkoma/secrets/jwt-signer";
              };
            };
          };
        };

        system.stateVersion = "22.11";
      };
  };
}
