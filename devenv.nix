{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  SECRETS_FILE = "./secrets.yaml";
  SECRETS_FILE_ENC = "./secrets.enc.yaml";
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in {
  packages = with pkgs; [
    git
    pkgs-unstable.esphome
    pkgs-unstable.esptool
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

  scripts.mqttui = {
    description = "Launch MQTT UI with credentials from secrets";
    packages = [ pkgs.mqttui ];
    exec = ''
      set -euo pipefail
      if [ ! -f "${SECRETS_FILE}" ]; then
        echo "Error: ${SECRETS_FILE} not found. Please decrypt secrets first."
        exit 1
      fi

      MQTT_IP=$(grep "mqtt_broker_ip:" ${SECRETS_FILE} | cut -d'"' -f2)
      MQTT_USER=$(grep "mqtt_broker_username:" ${SECRETS_FILE} | cut -d'"' -f2)
      MQTT_PASS=$(grep "mqtt_broker_password:" ${SECRETS_FILE} | cut -d'"' -f2)

      echo "Connecting to MQTT broker at $MQTT_IP as $MQTT_USER..."
      exec mqttui --broker "mqtt://$MQTT_IP" --username "$MQTT_USER" --password "$MQTT_PASS" "$@"
    '';
  };

  tasks = {
    "esphome:dashboard".exec = "esphome dashboard --open-ui --address localhost ./devices";
  };

  git-hooks.hooks = {
    typos.enable = true;
  };

  enterShell = ''
    figlet MyESPHome | lolcat
    
    if [ -f "${SECRETS_FILE_ENC}" ] && [ ! -f "${SECRETS_FILE}" ]; then
      decrypt-secrets
    fi
  '';
}
