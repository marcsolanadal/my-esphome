{
  description = "ESPHome configuration module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, lib, pkgs, ... }: {
      options = {
        services.esphome-configs = {
          enable = lib.mkEnableOption "ESPHome configs";
         
          repository = lib.mkOption {
            type = lib.types.str;
            description = "URL of the Git repository containing ESPHome configs";
            example = "https://github.com/your-username/your-repo.git";
          };
         
          branch = lib.mkOption {
            type = lib.types.str;
            default = "main";
            description = "Branch to use from the repository";
          };
         
          rev = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Specific commit hash to use (optional)";
          };
        };
      };

      config = lib.mkIf config.services.esphome-configs.enable {
        systemd.tmpfiles.rules = [
          "d /var/lib/esphome 0755 root root -"
        ];

        system.activationScripts.fetchEsphomeConfigs = {
          deps = [];
          text = let
            gitArgs = {
              url = config.services.esphome-configs.repository;
              ref = config.services.esphome-configs.branch;
            } // lib.optionalAttrs (config.services.esphome-configs.rev != "") {
              rev = config.services.esphome-configs.rev;
            };
          in ''
            rm -rf /var/lib/esphome/*
            cp -r ${builtins.fetchGit gitArgs}/* /var/lib/esphome/
            chown -R root:root /var/lib/esphome
            chmod -R 755 /var/lib/esphome
          '';
        };
      };
    };
  };
}
