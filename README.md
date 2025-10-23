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

```bash
# Install ESPHome
nix-shell -p esphome

# Compile a device
esphome compile devices/llum-cuina.yaml

# Flash over-the-air 📡
esphome run devices/llum-cuina.yaml --device 10.0.20.34

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

# View logs 👀
esphome logs devices/your-device.yaml --device IP

# Flash via USB 🔌
esphome run devices/your-device.yaml --device /dev/ttyUSB0
```

## 🎯 Pro Tips

- 💡 Use `esphome config` to validate befhostnameore flashing
- 🔄 OTA updates save climbing ladders!
- 📊 Web interface at `http://device-name.local`

---

*Happy automating! 🏠✨*
