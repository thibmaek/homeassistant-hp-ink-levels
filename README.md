# Home Assistant HP printer ink levels

🖨 Get ink levels from a HP printer and broadcast them as MQTT sensors to Home Assistant

## Prerequirements

All these packages are required and available via apt:

- `cups`
- `hplip`
- `bash`, probably already installed
- `mosquitto`, `mosquitto-clients`
- `cron` (or systemd if that works for you), probably already installed

## Setup

Add your printer to hplip:

```console
# hplip tries to launch a GUI, when you are running headless/lite add the -i flag to enter interactive mode
$ hp-setup -i hp5510.local
```

Download the script to a location and make it executable if not already:

```console
$ wget https://raw.githubusercontent.com/thibmaek/homeassistant-hp-ink-levels/master/get-hp-ink-levels.sh -P /home/pi
$ chmod +x /home/pi/get-hp-ink-levels.sh
```

Edit the lines where it says MQTT_USER= and MQTT_PASS= in the script. You can also edit the host and port if needed. As an alternative, exposing an env var in your shell with the same keys should also work.

Install it as a cron service:

```console
# This will add the script located at /home/pi to the cron service, which will run every 5 minutes
$ (crontab -l 2>/dev/null; echo "*/5 * * * * bash /home/pi/get-ink-levels.sh") | crontab -
```

Ink levels will now be published to topic: `homeassistant/sensor/hp-printer/color-#`. Subscribe to this topic to see the changes or add the sensors directly in Home Assistant as a MQTT sensor:

```yaml
sensor:
  ...
  - platform: mqtt
    name: printer_ink_level_cyan
    state_topic: homeassistant/sensor/hp-printer/color-cyan
    friendly_name: "Ink level (Cyan)"
    icon: mdi:alpha-c-box
    unit_of_measurement: '%'
  ...
```

## Troubleshooting

- Printer ink levels can only be retrieved when your printer is turned on. They will reflect latest known state in Home Assistant though.

- If colors and levels mismatch, make sure to check the order that gets returned from hplip matches the order of the array in the script. I've found that my HP5510 returned something different than a 5520. Run `hp-info -i` and check the order of agent1, agent2, agent3, agent4 and their color. Match that to the order of the array and it should be fine. If you're using 'counterfeit' (cheaper, non HP properietary shit) cartridges, those might get bumped to the beginning of the list.

- If you're getting 0 as the level on a cartridge you know is full, it's because HP blocks them since they are 'counterfeit'.
