#!/bin/bash

# Enable TCP/IP mode
adb tcpip 5555
sleep 3

# Get phone IP
IP=$(adb shell ip -f inet addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)

if [ -z "$IP" ]; then
  echo "Could not get phone IP, aborting"
  exit 1
fi

# Connect over WiFi
adb connect "$IP"


scrcpy -s "$IP:5555"
# scrcpy -s 192.168.100.109:5555
