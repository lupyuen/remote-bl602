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
## Remember to install blflash as superuser: sudo cargo install blflash
## Based on https://www.ics.com/blog/gpio-programming-using-sysfs-interface

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

##  Add Rust to the PATH
source $HOME/.cargo/env

set +x  ##  Disable echo
echo "----- Download the latest Upstream NuttX Release"
set -x  ##  Enable echo
wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/upstream-$(date +'%Y-%m-%d')/nuttx.zip -O /tmp/nuttx.zip
pushd /tmp
unzip -o nuttx.zip
popd
set +x  ##  Disable echo

echo "----- Enable GPIO 2"
if [ ! -d /sys/class/gpio/gpio2 ]; then
    echo 2 >/sys/class/gpio/export
fi

echo "----- Enable GPIO 3"
if [ ! -d /sys/class/gpio/gpio3 ]; then
    echo 3 >/sys/class/gpio/export
fi

echo "----- Set GPIO 2 and 3 as output"
echo out >/sys/class/gpio/gpio2/direction
echo out >/sys/class/gpio/gpio3/direction

echo "----- Set GPIO 2 to High (BL602 Flashing Mode)"
echo 1 >/sys/class/gpio/gpio2/value
sleep 1

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo 1 >/sys/class/gpio/gpio3/value
sleep 1
echo 0 >/sys/class/gpio/gpio3/value
sleep 1
echo 1 >/sys/class/gpio/gpio3/value
sleep 1

# echo "----- BL602 is now in Flashing Mode"
# cat /dev/ttyUSB0 &
# sleep 2
# kill %1
# echo

echo "----- Flash BL602 over USB UART with blflash"
set -x  ##  Enable echo
blflash flash /tmp/nuttx.bin --port /dev/ttyUSB0
sleep 1
set +x  ##  Disable echo

echo "----- Set GPIO 2 to Low (BL602 Normal Mode)"
echo 0 >/sys/class/gpio/gpio2/value
sleep 1

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo 1 >/sys/class/gpio/gpio3/value
sleep 1
echo 0 >/sys/class/gpio/gpio3/value
sleep 1
echo 1 >/sys/class/gpio/gpio3/value
sleep 1

echo "----- BL602 is now in Normal Mode"
stty -F /dev/ttyUSB0 raw 2000000
cat /dev/ttyUSB0 &

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo 1 >/sys/class/gpio/gpio3/value
sleep 1
echo 0 >/sys/class/gpio/gpio3/value
sleep 1
echo 1 >/sys/class/gpio/gpio3/value
sleep 1

echo
echo "----- TODO: Capture the BL602 output over USB UART"
sleep 5
kill %1

echo "----- Disable GPIO 2"
echo 2 >/sys/class/gpio/unexport

echo "----- Disable GPIO 3"
echo 3 >/sys/class/gpio/unexport
