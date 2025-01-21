# MY ESPHOME

A list of useful commads to get going with ESPHome in the command line.

- Install: `nix-shell -p esphome`
- Compile: `esphome compile persiana-marc-nord.yaml`
- Compile + OTA: `esphome run persiana-marc-nord.yaml --device 10.0.20.25`

## Shortcuts

```sh
esphome run llum-cuina.yaml --device 10.0.20.34
esphome run persiana-marc-piscina.yaml --device 10.0.20.24
```

All-in-one command:

```sh
nix-shell -p esphome --run "esphome run llum-cuina.yaml --device 10.0.20.34"
```