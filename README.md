# MY ESPHOME

A list of useful commands to get going with ESPHome in the command line.

- Install: `nix-shell -p esphome`
- Compile: `esphome compile persiana-marc-nord.yaml`
- Compile + OTA: `esphome run persiana-marc-nord.yaml --device 10.0.20.25`

## Dashboard

To open the dashboard we use the task runner that comes with devenv.

```bash
devenv tasks run dashboard:serve
```

## Shortcuts

```sh
esphome run llum-cuina.yaml --device 10.0.20.34
esphome run persiana-marc-piscina.yaml --device 10.0.20.24
```

- OTA firmware upgrade

```sh
nix-shell -p esphome --run "esphome run llum-cuina.yaml --device 10.0.20.34"
```

> NOTE: The Device IP is not necessary. I assume that the script know the IP defined in the `wifi.vars.staticIp`.
```sh
nix-shell -p esphome --run "esphome run llum-cuina.yaml --device OTA"
```

- Show logs of a specific device

    ```sh
    nix-shell -p esphome --run "esphome logs llum-cuina.yaml --device 10.0.20.34"
    ```



