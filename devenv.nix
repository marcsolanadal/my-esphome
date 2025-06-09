{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  packages = with pkgs; [git esphome];

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
  '';

  git-hooks.hooks = {
    # yamllint.enable = true;
    # yamlfmt.enable = true;
    typos.enable = true;
  };
}
