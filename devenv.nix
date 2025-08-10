{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  SECRETS_FILE = "./devices/secrets.yaml";
  SECRETS_FILE_ENC = "./devices/secrets.enc.yaml";
in {
  packages = with pkgs; [
    git
    esphome
    age
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
    cat <<'EOF'
    __  ___         _____  _____ ______  _   _
    |  \/  |        |  ___|/  ___|| ___ \| | | |
    | .  . | _   _  | |__  \ `--. | |_/ /| |_| |  ___   _ __ ___    ___
    | |\/| || | | | |  __|  `--. \|  __/ |  _  | / _ \ | '_ ` _ \  / _ \
    | |  | || |_| | | |___ /\__/ /| |    | | | || (_) || | | | | ||  __/
    \_|  |_/ \__, | \____/ \____/ \_|    \_| |_/ \___/ |_| |_| |_| \___|
              __/ |
             |___/
    EOF

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
