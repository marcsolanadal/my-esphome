# ESPHome Scheduled Actions Package

A powerful package-based system for MQTT-driven action scheduling with persistence and recurring support for ESPHome devices.

## Features

- ✅ **MQTT-based scheduling** - Send action queues via MQTT
- ✅ **Flash persistence** - Actions survive device reboots
- ✅ **Recurring actions** - Daily schedules with day-of-week filtering
- ✅ **Generic action handling** - Support any device type via user callbacks
- ✅ **Queue management** - Add, remove, clear actions via MQTT
- ✅ **Status monitoring** - Template sensors for queue visibility
- ✅ **Integration friendly** - Respects halt-automations and existing patterns
- ✅ **Error handling** - Comprehensive validation and error reporting

## Installation

### Step 1: Add Package to Device Configuration

```yaml
packages:
  scheduled_actions: !include
    file: ../packages/scheduled-actions/scheduled-actions.yaml
    vars:
      topic_prefix: ${topic_prefix}
```

### Step 2: Define Action Handler

Override the `scheduled_action_trigger` script to handle your device-specific actions:

```yaml
script:
  - id: scheduled_action_trigger
    then:
      - lambda: |-
          // Parse action data
          StaticJsonDocument<512> action_doc;
          deserializeJson(action_doc, id(current_action_data));

          // Handle your device actions here
          if (action_doc["device"] == "shutter") {
            float position = action_doc["position"].as<float>();
            auto call = id(my_cover).make_call();
            call.set_position(position / 100.0f);
            call.perform();
          }
```

## Usage

### Action Queue Format

Send JSON arrays to `{topic_prefix}/action-queue`:

```json
[
  {
    "id": "unique_action_id",
    "time": "2025-01-15T08:00:00Z",
    "action": {
      "device": "shutter",
      "position": 50
    }
  }
]
```

### Recurring Actions

Add a `recurring` object for daily schedules:

```json
{
  "id": "daily_close",
  "time": "2025-01-15T20:00:00Z",
  "action": {
    "device": "shutter",
    "command": "close"
  },
  "recurring": {
    "type": "daily",
    "days": ["mon", "tue", "wed", "thu", "fri"]
  }
}
```

## MQTT Topics

### Publishing Actions

| Topic | Payload | Description |
|-------|---------|-------------|
| `{prefix}/action-queue` | JSON Array | Replace entire action queue |
| `{prefix}/scheduled-actions/clear` | Any | Clear all actions |
| `{prefix}/scheduled-actions/status` | Any | Request status info |
| `{prefix}/scheduled-actions/dump` | Any | Get full queue dump |

### Status Updates

| Topic | Description |
|-------|-------------|
| `{prefix}/scheduled-actions/status` | Queue update confirmations |
| `{prefix}/scheduled-actions/info` | Detailed status response |
| `{prefix}/scheduled-actions/executed` | Action execution notifications |
| `{prefix}/scheduled-actions/error` | Error messages |
| `{prefix}/scheduled-actions/queue-dump` | Full queue contents |

## Template Sensors

The package provides monitoring sensors:

- **Next Action**: `{friendly_name} Next Scheduled Action`
- **Last Executed**: `{friendly_name} Last Action Executed`

## Examples

### 1. Shutter Control

```yaml
script:
  - id: scheduled_action_trigger
    then:
      - lambda: |-
          StaticJsonDocument<512> doc;
          deserializeJson(doc, id(current_action_data));

          if (doc["device"] == "shutter") {
            if (doc.containsKey("position")) {
              float pos = doc["position"].as<float>() / 100.0f;
              id(my_shutter).make_call().set_position(pos).perform();
            } else if (doc["command"] == "open") {
              id(my_shutter).make_call().set_command_open().perform();
            } else if (doc["command"] == "close") {
              id(my_shutter).make_call().set_command_close().perform();
            }
          }
```

**Example Queue:**
```json
[
  {
    "id": "morning_open",
    "time": "2025-01-15T08:00:00Z",
    "action": {"device": "shutter", "command": "open"},
    "recurring": {"type": "daily", "days": ["mon","tue","wed","thu","fri"]}
  },
  {
    "id": "evening_close",
    "time": "2025-01-15T20:00:00Z",
    "action": {"device": "shutter", "command": "close"},
    "recurring": {"type": "daily"}
  }
]
```

### 2. Light Control

```yaml
script:
  - id: scheduled_action_trigger
    then:
      - lambda: |-
          StaticJsonDocument<512> doc;
          deserializeJson(doc, id(current_action_data));

          if (doc["device"] == "light") {
            if (doc["state"] == "on") {
              id(my_light).turn_on();
              if (doc.containsKey("brightness")) {
                id(my_light).make_call()
                  .set_brightness(doc["brightness"].as<float>() / 100.0f)
                  .perform();
              }
            } else {
              id(my_light).turn_off();
            }
          }
```

**Example Queue:**
```json
[
  {
    "id": "evening_lights_on",
    "time": "2025-01-15T19:00:00Z",
    "action": {
      "device": "light",
      "state": "on",
      "brightness": 80
    },
    "recurring": {"type": "daily"}
  },
  {
    "id": "night_lights_off",
    "time": "2025-01-15T23:00:00Z",
    "action": {
      "device": "light",
      "state": "off"
    },
    "recurring": {"type": "daily"}
  }
]
```

### 3. Multi-Device Actions

```yaml
script:
  - id: scheduled_action_trigger
    then:
      - lambda: |-
          StaticJsonDocument<512> doc;
          deserializeJson(doc, id(current_action_data));

          std::string device = doc["device"].as<std::string>();

          if (device == "shutter") {
            // Handle shutter actions
            float pos = doc["position"].as<float>() / 100.0f;
            id(bedroom_shutter).make_call().set_position(pos).perform();

          } else if (device == "light") {
            // Handle light actions
            if (doc["state"] == "on") {
              id(bedroom_light).turn_on();
            } else {
              id(bedroom_light).turn_off();
            }

          } else if (device == "fan") {
            // Handle fan actions
            if (doc["state"] == "on") {
              id(ceiling_fan).turn_on();
              if (doc.containsKey("speed")) {
                id(ceiling_fan).make_call()
                  .set_speed(doc["speed"].as<int>())
                  .perform();
              }
            } else {
              id(ceiling_fan).turn_off();
            }
          }
```

## Integration with Existing Systems

### Home Assistant Integration

Use MQTT automations to send action queues:

```yaml
automation:
  - alias: "Send Weekly Shutter Schedule"
    trigger:
      - platform: time
        at: "00:00:00"
    action:
      - service: mqtt.publish
        data:
          topic: "bedroom_shutter/action-queue"
          payload: |
            [
              {
                "id": "weekday_open",
                "time": "{{ (now() + timedelta(hours=8)).strftime('%Y-%m-%dT%H:%M:%SZ') }}",
                "action": {"device": "shutter", "command": "open"},
                "recurring": {"type": "daily", "days": ["mon","tue","wed","thu","fri"]}
              }
            ]
```

### Node-RED Integration

Create flows to dynamically generate and send action queues based on weather, occupancy, or other sensors.

## Monitoring and Debugging

### Status Check
```bash
mosquitto_pub -h broker.local -t "bedroom_shutter/scheduled-actions/status" -m ""
```

### Queue Dump
```bash
mosquitto_pub -h broker.local -t "bedroom_shutter/scheduled-actions/dump" -m ""
```

### Clear Queue
```bash
mosquitto_pub -h broker.local -t "bedroom_shutter/scheduled-actions/clear" -m ""
```


## Advanced Configuration

### Memory Optimization

For devices with limited memory, reduce the JSON document size:

```yaml
# In scheduled-actions.yaml, change:
StaticJsonDocument<2048> doc;  # to smaller size like 1024
```

### Custom Validation

Add custom validation in the MQTT handler:

```yaml
mqtt:
  on_message:
    - topic: ${topic_prefix}/action-queue
      then:
        - lambda: |-
            // Add custom validation here before storing
            // e.g., check time is not in the past, validate action format, etc.
```

## Troubleshooting

### Common Issues

1. **Actions not executing**: Check that time synchronization is working (`sntp_time`)
2. **JSON parsing errors**: Validate JSON format using online validators
3. **Memory issues**: Reduce queue size or JSON document buffer size
4. **Time format errors**: Ensure ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

### Debug Logging

Enable verbose logging:

```yaml
logger:
  level: DEBUG
  logs:
    scheduled_actions: VERBOSE
```

### Status Monitoring

Monitor the template sensors in your dashboard:
- Next action should show the earliest scheduled time
- Last action should update when actions execute

## Performance Considerations

- **Queue Size**: Recommended maximum 50 actions for optimal performance
- **Check Interval**: Default 60s interval balances accuracy vs performance
- **Memory Usage**: ~2KB for JSON parsing buffer + queue storage
- **Flash Writes**: Actions are persisted only when queue changes

## Integration with Project Patterns

This package follows your existing ESPHome project patterns:

- **Uses existing MQTT infrastructure** from `common/mqtt.yaml`
- **Respects halt-automations** from `packages/halt-automations.yaml`
- **Integrates with time sync** from `common/time.yaml`
- **Follows substitution patterns** like `${topic_prefix}` and `${friendly_name}`
- **Package-based architecture** for easy inclusion in device configs
- **Template sensors** for monitoring like other packages in your project

## Files in this Package

- `scheduled-actions.yaml` - Main package implementation
- `test-device.yaml` - Example test device configuration (based on persiana-dormitori structure)
- `README.md` - This documentation

## Test Device Configuration

The included `test-device.yaml` follows the same structure as `persiana-dormitori`:

- Uses Shelly 2.5 hardware package directly
- Includes individual common packages (wifi, mqtt, logger, etc.)
- Implements current-based cover with safety features
- Includes comprehensive test automations for validation

To use the test device:

1. Copy `test-device.yaml` to your `devices/` folder
2. Rename appropriately (e.g., `shutter-scheduled-test.yaml`)
3. Update device substitutions and network settings
4. Flash to your Shelly 2.5 device

## License

This package is designed for the my-esphome project and follows the same patterns and conventions established in the existing codebase.