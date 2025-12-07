# 🏠 My Smart Home ESPHome Hub

Welcome to my cozy smart home setup! 🌟 This repository contains all my ESPHome device configurations for controlling lights, shutters, and other smart devices around the house.

## 🗂️ Project Structure

```
📁 devices/           # 🔌 All your smart device configs
📁 common/            # 🛠️ Shared configurations (wifi, mqtt, etc.)
📁 hardware/          # 🔧 Hardware-specific templates (Shelly devices)
📁 packages/          # 📦 Reusable functionality packages
🔐 secrets.yaml      # Your secret credentials (gitignored)
```

## 🚀 Quick Start

### Podman

```bash
podman create -it \ 
  --name esphome-dev \
  -p 6052:6052 \
  --cap-add=NET_RAW \ # Allows the container to find devices using mDNS
  -v $PWD:/workspace \
  esphome-dev
podman start esphome-dev
podman exec -it esphome-dev bash
```

NOTE: We should also add the `--device \dev/ttyUSB0` to flash the firmware into a device. Seems that this feature doesn't work in MacOS but I need to try it. (See https://esphome.io/guides/getting_started_command_line/ for more info).  
---


```bash
# Compile a device
esphome compile devices/llum-cuina.yaml

# Flash over-the-air 📡
esphome run devices/llum-cuina.yaml --device OTA

# Start dashboard 🎛️
devenv tasks run dashboard:serve
```

## 🏡 My Devices

### 💡 Lights
- **llum-cuina** - Kitchen RGBW with effects
- **llum-ambient-dormitori** - Bedroom mood lighting
- **llum-escala** - Auto stairs light
- **llum-ventilador-*** - Fan lights

### 🪟 Shutters
- **persiana-dormitori** - Bedroom shutter
- **persiana-marc-*** - Living area shutters

## 🛠️ Useful Commands

```bash
# Check config 🔍
esphome config devices/your-device.yaml

# Flash via USB 🔌
esphome run devices/your-device.yaml --device /dev/ttyUSB0

# View logs 👀
esphome logs devices/your-device.yaml --device OTA
```

## 🎯 Pro Tips

- 💡 Use `esphome config` to validate befhostnameore flashing
- 🔄 OTA updates save climbing ladders!
- 📊 Web interface at `http://device-name.local`

---

*Happy automating! 🏠✨*
