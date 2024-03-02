{ lib, config, ... }:
with lib;
let cfg = config.biene.services.monitoring.prometheus;
in
{

  options.biene.services.monitoring.prometheus = {
    enable = mkEnableOption "prometheus";
    port = mkOption {
      type = types.int;
      default = 9001;
      example = 9001;
      description = "Port for prometheus";
    };
  };
  config = mkIf cfg.enable
    {

      services.prometheus = {
        enable = true;
        port = cfg.port;
        # Disable config checks. They will fail because they run sandboxed and
        # can't access external files, e.g. the secrets stored in /run/keys
        # https://github.com/NixOS/nixpkgs/blob/d89d7af1ba23bd8a5341d00bdd862e8e9a808f56/nixos/modules/services/monitoring/prometheus/default.nix#L1732-L1738
        checkConfig = false;

        extraFlags =
          [ "--log.level=debug" "--storage.tsdb.retention.size='6GB'" ];
        scrapeConfigs = [
          {
            job_name = "pretix-app-stats";
            static_configs = [{
              targets = [ "tickets.zugvoegelfestival.org" ];
            }];
            basic_auth =
              {
                username = "user";
                password = "password";
              };
          }
          {
            job_name = "pretix-server-stats";
            static_configs = [{
              targets = [ "status.loco.vision" ];
            }];
          }
        ];
      };
    };
}

