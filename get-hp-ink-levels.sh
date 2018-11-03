#!/usr/bin/env bash
set -e

$MQTT_HOST=hassio.local
MQTT_PORT=1883
MQTT_USER=
MQTT_PASS=

INK_LEVELS=$(hp-info 2>&1 | grep -oP "(?<=agent[1-4]-level\\s{18})(.*\\S)" | tr "\\n" ",")

# These have to maintain order since they match the output of hplip's hp-info binary
COLORS=(
  'black'
  'cyan'
  'magenta'
  'yellow'
)

if [ -n "${INK_LEVELS}" ]; then
  IFS=',' read -r -a ink_levels_array <<< "$INK_LEVELS"

  for index in "${!ink_levels_array[@]}"
  do
    if [ -n "${ink_levels_array[index]}" ]; then
      echo "${COLORS[index]} ${ink_levels_array[index]}%"
      mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u "$MQTT_USER" -P "$MQTT_PASS" \
        -t "homeassistant/sensor/hp-printer/color-${COLORS[index]}" -m "${ink_levels_array[index]}"
    fi
  done
fi
