#!/usr/bin/env bash
## Auto Flash and Test BL602 with GPIO Control on Linux SBC.
## Pins to be connected:
## | SBC    | BL602    | Function
## | -------|----------|----------
## | GPIO 2 | GPIO 8   | Flashing Mode
## | GPIO 3 | RST      | Reset
## | GND    | GND      | Ground
## | USB    | USB      | USB UART

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

##  Default Build Prefix is "upstream"
if [ "$BUILD_PREFIX" == '' ]; then
    export BUILD_PREFIX=upstream
fi

##  Default Build Date is today (YYYY-MM-DD)
if [ "$BUILD_DATE" == '' ]; then
    export BUILD_DATE=$(date +'%Y-%m-%d')
fi

##  Default USB Device is /dev/ttyUSB0
if [ "$USB_DEVICE" == '' ]; then
    export USB_DEVICE=/dev/ttyUSB0
fi

##  Add Rust to the PATH
source $HOME/.cargo/env

set +x  ##  Disable echo
echo "----- Download the latest $BUILD_PREFIX NuttX build for $BUILD_DATE"
set -x  ##  Enable echo
wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/$BUILD_PREFIX-$BUILD_DATE/nuttx.zip -O /tmp/nuttx.zip
pushd /tmp
unzip -o nuttx.zip
popd
set +x  ##  Disable echo

echo "----- Enable GPIO 2 and 3"
if [ ! -d /sys/class/gpio/gpio2 ]; then
    echo 2 >/sys/class/gpio/export ; sleep 1  ##  Must sleep or next GPIO command will fail with "Permission Denied"
fi
if [ ! -d /sys/class/gpio/gpio3 ]; then
    echo 3 >/sys/class/gpio/export ; sleep 1  ##  Must sleep or next GPIO command will fail with "Permission Denied"
fi

echo "----- Set GPIO 2 and 3 as output"
echo out >/sys/class/gpio/gpio2/direction
echo out >/sys/class/gpio/gpio3/direction

echo "----- Set GPIO 2 to High (BL602 Flashing Mode)"
echo 1 >/sys/class/gpio/gpio2/value ; sleep 1

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1
echo 0 >/sys/class/gpio/gpio3/value ; sleep 1
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602 again)"
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1
echo 0 >/sys/class/gpio/gpio3/value ; sleep 1
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1

echo "----- BL602 is now in Flashing Mode"
echo "----- Flash BL602 over USB UART with blflash"
set -x  ##  Enable echo
blflash flash /tmp/nuttx.bin --port $USB_DEVICE
set +x  ##  Disable echo
sleep 1

echo "----- Set GPIO 2 to Low (BL602 Normal Mode)"
echo 0 >/sys/class/gpio/gpio2/value ; sleep 1

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1
echo 0 >/sys/class/gpio/gpio3/value ; sleep 1
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1

echo "----- BL602 is now in Normal Mode"

##  Set USB UART to 2 Mbps
stty -F $USB_DEVICE raw 2000000

##  Show the BL602 output and capture to /tmp/test.log.
##  Run this in the background so we can kill it later.
cat $USB_DEVICE | tee /tmp/test.log &

echo "----- Toggle GPIO 3 High-Low-High (Reset BL602)"
echo "----- Here is the BL602 Output..."
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1
echo 0 >/sys/class/gpio/gpio3/value ; sleep 1
echo 1 >/sys/class/gpio/gpio3/value ; sleep 1

##  Wait a while for BL602 to finish booting
sleep 1

##  Check whether BL602 has crashed
set +e  ##  Don't exit when any command fails
match=$(grep "registerdump" /tmp/test.log)
set -e  ##  Exit when any command fails

if [ "$match" == "" ]; then
    ##  If BL602 has not crashed, send the test command to BL602
    # echo "uname -a" >$USB_DEVICE ; sleep 1
    # echo "ls /dev" >$USB_DEVICE ; sleep 1
    # echo "spi_test2" >$USB_DEVICE ; sleep 5

    # echo ; echo "----- Send command to BL602: lorawan_test" ; sleep 2
    # echo "" >$USB_DEVICE
    # echo "lorawan_test" >$USB_DEVICE

    ##  Wait a while for the test command to run
    sleep 30

    ##  Check whether BL602 has joined the LoRaWAN Network
    set +e  ##  Don't exit when any command fails
    match=$(grep "JOINED" /tmp/test.log)
    set -e  ##  Exit when any command fails

    ##  If BL602 has joined the LoRaWAN Network, then everything is super hunky dory!
    if [ "$match" != "" ]; then
        echo; echo "===== All OK! BL602 has successfully joined the LoRaWAN Network"

    else
        ##  Check whether NuttX has booted properly
        set +e  ##  Don't exit when any command fails
        match=$(grep "command not found" /tmp/test.log)
        set -e  ##  Exit when any command fails

        ##  If NuttX has booted properly, show the status
        if [ "$match" != "" ]; then
            echo; echo "===== Boot OK"
        else
            echo; echo "===== Unknown Status"
            test_status=unknown
        fi
    fi

else
    ##  If BL602 has crashed, do the Crash Analysis
    echo; echo "===== Boot FAILED. Below is the Crash Analysis"; echo

    ##  Don't exit when any command fails (grep)
    set +e

    ##  Find all code addresses 23?????? in the Output Log, remove duplicates, skip 23007000.
    ##  Returns a newline-delimited list of addresses: "23011000\n230053a0\n..."
    grep --extended-regexp \
        --only-matching \
        "23[0-9a-f]{6}" \
        /tmp/test.log \
        | grep -v "23007000" \
        | uniq \
        >/tmp/test.addr

    ##  For every address, show the corresponding line in the disassembly
    for addr in $(cat /tmp/test.addr); do
        ##  Skip addresses that don't match
        match=$(grep "$addr:" /tmp/nuttx.S)
        if [ "$match" != "" ]; then
            echo "----- Code Address $addr"
            grep \
                --context=5 \
                --color=auto \
                "$addr:" \
                /tmp/nuttx.S
            echo
        fi
    done

    ##  Find all data addresses 42?????? in the Output Log, remove duplicates.
    ##  Returns a newline-delimited list of addresses: "23011000\n230053a0\n..."
    grep --extended-regexp \
        --only-matching \
        "42[0-9a-f]{6}" \
        /tmp/test.log \
        | uniq \
        >/tmp/test.addr

    ##  For every address, show the corresponding line in the disassembly
    for addr in $(cat /tmp/test.addr); do
        ##  Skip addresses that don't match
        match=$(grep "^$addr" /tmp/nuttx.S)
        if [ "$match" != "" ]; then
            echo "----- Data Address $addr"
            grep \
                --color=auto \
                "^$addr" \
                /tmp/nuttx.S \
                | grep -v "noinit"
            echo
        fi
    done

    ##  Exit when any command fails
    set -e
fi

##  Kill the background task that captures the BL602 output
kill %1

##  We don't disable GPIO 2 and 3 because otherwise BL602 might keep rebooting
echo

##  If status is unknown, start the second script
if [ "$test_status" == "unknown" ]; then
    read -p "Disconnect and reconnect the USB cable. Press Enter to continue..."
    SCRIPT_PATH="${BASH_SOURCE}"
    SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
    $SCRIPT_DIR/test2.sh
fi

##  TODO: Capture the script output and write it to the Body of the GitHub Release
##  script -c "sudo remote-bl602/scripts/test.sh" /tmp/test.script
##  See https://docs.github.com/en/rest/reference/releases#update-a-release