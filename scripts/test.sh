#!/usr/bin/env bash
## Auto Flash and Test BL602 with GPIO Control on Linux SBC.
## (1) Before Flashing BL602: Set GPIO 8 to High and toggle the Reset Pin
## (2) Flash BL602 over USB UART with blflash
## (3) After Flashing BL602: Set GPIO 8 to Low and toggle the Reset Pin
## (4) Capture the BL602 output over USB UART
## Pins to be connected:
## | SBC    | BL602    | Function
## | -------|----------|----------
## | GPIO 2 | GPIO 8   | Flashing Mode
## | GPIO 3 | GPIO RST | Reset
## Based on https://www.ics.com/blog/gpio-programming-using-sysfs-interface

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

## Download the latest Upstream NuttX Release
wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/upstream-$(date +'%Y-%m-%d')/nuttx.zip -O /tmp/nuttx.zip
pushd /tmp
unzip -o nuttx.zip
popd

## Enable GPIO 2 if not enabled
if [ ! -d /sys/class/gpio/gpio2 ]; then
    echo 2 >/sys/class/gpio/export
fi

## Set GPIO 2 as output
echo out >/sys/class/gpio/gpio2/direction

## Set GPIO 2 to High (BL602 Flashing Mode)
echo 1 >/sys/class/gpio/gpio2/value

## TODO: Toggle GPIO 3 (Reset BL602) and flash BL602 over USB UART with blflash

## Wait a while (for testing)
sleep 10

## Set GPIO 2 to Low (BL602 Non-Flashing Mode)
echo 0 >/sys/class/gpio/gpio2/value

## TODO: Toggle GPIO 3 (Reset BL602) and capture the BL602 output over USB UART

## Wait a while (for testing)
sleep 10

## Disable GPIO 2
echo 2 >/sys/class/gpio/unexport
