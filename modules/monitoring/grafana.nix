{ lib, config, ... }:
with lib;
let
  cfg = config.biene.services.monitoring.grafana;
in
{
  options.biene.services.monitoring.grafana = {
    enable = mkEnableOption "Grafana";

    domain = mkOption {
      type = types.str;
      example = "grafana.myhost.com";
      description = "Domain for grafana";
    };
    port = mkOption {
      type = types.int;
      default = 3000;
      example = 3000;
      description = "Port for grafana";
    };
    acmeMail = mkOption {
      type = types.str;
      default = null;
      example = "admin@pretix.eu";
      description = "Email for SSL Certificate Renewal";
    };
  };

  config = mkIf cfg.enable {

    # Backup Graphana dir, contains stateful config
    #biene.services.backup.backupDirs = [ "/var/lib/grafana" ];

    # Graphana frontend
    services.grafana = {

      enable = true;

      settings = {
        server = {
          domain = cfg.domain;
          http_port = cfg.port;
          http_addr = "127.0.0.1";
        };

        # Mail notifications
        # smtp = {
        #  enabled = false;
        #  host = "smtp.sendgrid.net:587";
        # user = "apikey";
        # passwordFile = "${config.lollypops.secrets.files."grafana/smtp-password".path}";
        # fromAddress = "status@pablo.tools";
        # };
      };
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "${cfg.acmeMail}";
    };


    # nginx reverse proxy
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyWebsockets = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
    #
    #      provision.datasources.settings =
    #        {
    #          datasources =
    #            [
    #              {
    #                name = "Prometheus localhost";
    #                url = "http://localhost:9090";
    #                type = "prometheus";
    #                isDefault = true;
    #              }
    #              {
    #                name = "loki";
    #                url = "http://localhost:3100";
    #                type = "loki";
    #              }
    #            ];
    #
    #        };
    #
  };
}

