#!/usr/bin/env bash
set -e  ##  Exit when any command fails
set -x  ##  Echo commands

cd ~/remote-bl602
git pull

##  Set the USB Device and Build Name
export USB_DEVICE=/dev/ttyUSB0

##  Run the script for Auto Flash and Test
rm -f /tmp/release.log
script -c ~/remote-bl602/scripts/test.sh /tmp/release.log

##  Clean up Test Log
rm -f /tmp/release2.log
echo '```text' >>/tmp/release2.log
cat /tmp/release.log >>/tmp/release2.log
echo '```' >>/tmp/release2.log
cp /tmp/release2.log /tmp/release.log

##  Upload the Test Log to the Release Notes
gh release edit \
    upstream-2022-05-09 \
    --notes-file /tmp/release.log \
    --repo lupyuen/incubator-nuttx

##  Shutdown
read -p "Press Enter to shutdown"
sudo shutdown now
