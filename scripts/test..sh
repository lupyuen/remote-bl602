#!/usr/bin/env bash
## Test GPIO Output on Linux SBC
## Based on https://www.ics.com/blog/gpio-programming-using-sysfs-interface
## Pins to be connected:
## | SBC    | BL602    | Function
## | -------|----------|----------
## | GPIO 2 | GPIO 8   | Flashing Mode
## | GPIO 3 | GPIO RST | Reset

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

## Enable GPIO 2
echo 2 >/sys/class/gpio/export
ls /sys/class/gpio/

## Set GPIO 2 as output
echo out >/sys/class/gpio/gpio2/direction

## Wait a while
sleep 5

## Set GPIO 2 to Low
echo 0 >/sys/class/gpio/gpio2/value

## Show GPIO 2 status
cat /sys/class/gpio/gpio2/value

## Set GPIO 2 to High
echo 1 >/sys/class/gpio/gpio2/value

## Show GPIO 2 status
cat /sys/class/gpio/gpio2/value

## Disable GPIO 2
echo 2 >/sys/class/gpio/unexport
ls /sys/class/gpio
