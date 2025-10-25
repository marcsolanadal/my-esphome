{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  SECRETS_FILE = "./secrets.yaml";
  SECRETS_FILE_ENC = "./secrets.enc.yaml";
in {
  packages = with pkgs; [
    git
    esphome
    esptool
    age
    lolcat
    figlet
  ];

  env.AGE_KEY_FILE = lib.mkDefault "~/.ssh/id_dev";

  scripts.encrypt-secrets = {
    description = "Encrypt secrets.yaml";
    exec = ''
      set -euo pipefail
      age -R ./.age-recipients -o ${SECRETS_FILE_ENC} ${SECRETS_FILE}
      echo "Encrypted → ${SECRETS_FILE_ENC}"
    '';
  };

  scripts.decrypt-secrets = {
    description = "Decrypt secrets.enc.yaml";
    exec = ''
      set -euo pipefail
      age -d -i ${config.env.AGE_KEY_FILE} -o ${SECRETS_FILE} ${SECRETS_FILE_ENC}
      echo "Decrypted → ${SECRETS_FILE}"
    '';
  };

  enterShell = ''
    figlet MyESPHome | lolcat
    
    if [ -f "${SECRETS_FILE_ENC}" ] && [ ! -f "${SECRETS_FILE}" ]; then
      decrypt-secrets
    fi
  '';

  tasks = {
    "dashboard:serve".exec = "esphome dashboard --open-ui --address localhost ./devices";
  };

  git-hooks.hooks = {
    typos.enable = true;
  };
}
