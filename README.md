# Flash and Test BL602 Remotely via a Linux Single-Board Computer

Read the article...

-   ["Auto Flash and Test NuttX on RISC-V BL602"](https://lupyuen.github.io/articles/auto)

Watch the demo on YouTube...

-   ["Auto Flash and Test on PineDio Stack BL604"](https://youtu.be/JX7rWqWTOW4)

-   ["Auto Flash and Test on PineCone BL602"](https://youtu.be/JtnOyl5cYjo)

This script runs on a Linux Single-Board Computer (SBC) to automagically Flash and Test BL602, with the Latest Daily Build of Apache NuttX OS.

The script sends the "`lorawan_test`" command to BL602 after booting, to test the LoRaWAN Stack.

If BL602 crashes, the script runs a Crash Analysis to show the RISC-V Disassembly of the addresses in the Stack Trace.

The scripts are here...

-   [scripts/test.sh](scripts/test.sh): Auto Flash and Test PineCone BL602

-   [scripts/pinedio.sh](scripts/pinedio.sh): Auto Flash and Test PineDio Stack BL604

-   [scripts/pinedio2.sh](scripts/pinedio2.sh): Called by pinedio.sh

-   [scripts/upload.sh](scripts/upload.sh): Upload Test Log to GitHub Release Notes

NuttX Builds are done by GitHub Actions...

-  [Daily Upstream Build](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602.yml) (Without the LoRaWAN Stack)

-  [Release Build](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602-commit.yml) (Includes the LoRaWAN Stack)

-  [Downstream Build](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602-downstream.yml) (Merges the LoRaWAN Stack with upstream updates)

-  [PineDio Stack BL604 Build](https://github.com/lupyuen/incubator-nuttx/blob/pinedio/.github/workflows/pinedio.yml) (Includes the LoRaWAN Stack, ST7789 Display Driver, Touch Panel Driver, LVGL Test App)

Why are we doing this?

-   Might be useful for __Release Testing__ of NuttX (and other operating systems) on real hardware

-   By auto-testing the __LoRaWAN Stack__ on NuttX, we can be sure that GPIO Input / Output / Interrupts, SPI, ADC, Timers, Message Queues, PThreads, Strong Random Number Generator and Internal Temperature Sensor are all working OK with the latest Daily Build of NuttX

-   I write articles about NuttX OS. I need to pick the __Latest Stable Build__ of NuttX for testing the NuttX code in my articles. [(Like these)](https://lupyuen.github.io/articles/book#nuttx-on-bl602)

# Run The Script

Watch the demo on YouTube...

-   ["Auto Flash and Test on PineCone BL602"](https://youtu.be/JtnOyl5cYjo)

Connect SBC to BL602 and SX1262 like so...

| SBC     | BL602    | SX1262 | Function
| --------|----------|--------|----------
| GPIO 2  | GPIO 8   |        | Flashing Mode
| GPIO 3  | RST      | RESET  | Reset
| GND     | GND      |        | Ground
| USB     | USB      |        | USB UART

For auto-testing LoRaWAN, also connect BL602 to SX1262 as described below...

- ["Connect SX1262"](https://lupyuen.github.io/articles/spi2#connect-sx1262)

To run the flash and test script for the __Daily Upstream Build__ (without LoRaWAN)...

```bash
##  Allow the user to access the GPIO and UART ports
sudo usermod -a -G gpio    $USER
sudo usermod -a -G dialout $USER

##  Logout and login to refresh the permissions
logout

##  Install rustup, select default option
sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh

##  Install blflash for flashing BL602
cargo install blflash

##  Download the flash and test script
git clone --recursive https://github.com/lupyuen/remote-bl602/

##  Auto flash and test BL602
remote-bl602/scripts/test.sh
```

(See the output log below)

To run the flash and test script for the __Release Build__ (includes LoRaWAN)...

```bash
##  Tell the script to download the Release Build (instead of the Upstream Build)
export BUILD_PREFIX=release

##  Auto flash and test BL602
remote-bl602/scripts/test.sh
```

(See the output log below)

To select the __Downstream Build__ by __Build Date__...

```bash
##  Tell the script to download the Downstream Build for 2022-05-04
export BUILD_PREFIX=downstream
export BUILD_DATE=2022-05-04

##  Auto flash and test BL602
remote-bl602/scripts/test.sh
```

For __PineDio Stack BL604__...

```bash
##  Auto flash and test PineDio Stack BL604: LoRaWAN Test
remote-bl602/scripts/pinedio.sh

##  Auto test PineDio Stack BL604: Touchscreen Test
remote-bl602/scripts/pinedio2.sh
```

(See the output log below)

We may also __flash and test BL602 remotely__ over SSH...

```bash
ssh my-sbc remote-bl602/scripts/test.sh
```

To __upload the Test Log__ to GitHub Release Notes...

```bash
##  Run the script for Auto Flash and Test, capture the Test Log
script -c remote-bl602/scripts/test.sh /tmp/release.log

##  Upload the Test Log to the GitHub Release Notes
remote-bl602/scripts/upload.sh
```

[(See the Test Log)](https://github.com/lupyuen/incubator-nuttx/releases/tag/pinedio-2022-05-10)

More about this below.

# PineDio Stack BL604

Watch the demo on YouTube...

-   ["Auto Flash and Test on PineDio Stack BL604"](https://youtu.be/JX7rWqWTOW4)

We connect PineDio Stack BL604 to the SBC for Auto Flash and Test like so...

| SBC     | BL604    | Function
| --------|----------|----------
| GPIO 5  | GPIO 8 _(GPIO Port)_  | Flashing Mode
| GPIO 6  | RST _(JTAG Port)_     | Reset
| GND     | GND _(JTAG Port)_     | Ground
| USB     | USB Port              | USB UART

__GPIO 8 Jumper must be set to Low (Non-Flashing Mode)!__

(Or the LoRaWAN Test App will fail because the timers will get triggered too quickly)

# Test PineDio Stack BL604

We auto flash and test PineDio Stack BL604 in two scripts.

The first script auto-flashes the PineDio Stack Firmware [(auto-built by GitHub Actions)](https://github.com/lupyuen/incubator-nuttx/blob/pinedio/.github/workflows/pinedio.yml) and runs the [LoRaWAN Test App](https://github.com/lupyuen/lorawan_test)...

-   [scripts/pinedio.sh](scripts/pinedio.sh)

The [LoRaWAN Test App](https://github.com/lupyuen/lorawan_test) connects to a LoRaWAN Gateway (ChirpStack) and sends a LoRaWAN Data Packet to the Gateway.

(Which means that Timers, SPI, GPIO Input / Ouput / Interrupt are working OK)

The second script auto-restarts PineDio Stack and runs the [LVGL Test App](https://github.com/lupyuen/lvgltest-nuttx) (to test the touchscreen)...

-   [scripts/pinedio2.sh](scripts/pinedio2.sh)

The [LVGL Test App](https://github.com/lupyuen/lvgltest-nuttx) renders a screen to the ST7789 SPI Display and waits for a Touch Event from the CST816S I2C Touch Panel.

For the test to succeed, we must tap the screen to generate a Touch Event.

[(Later we might automate this with a "Robot Finger")](https://youtu.be/mb3zcacDGPc)

(See the output log below)

# Select USB Device

When we connect both PineDio Stack BL604 and PineCone BL602 to the SBC, we'll see two USB Devices: `/dev/ttyUSB0` and `/dev/ttyUSB1`

How will we know which USB Device is for PineDio Stack and PineCone?

```bash
## Show /dev/ttyUSB0
lsusb -v -s 1:3 2>&1 | grep bcdDevice | colrm 1 23

## Show /dev/ttyUSB1
lsusb -v -s 1:4 2>&1 | grep bcdDevice | colrm 1 23

## Output for Pinedio Stack BL604:
## 2.64
## See https://gist.github.com/lupyuen/dc8c482f2b31b25d329cd93dc44f0044

## Output for PineCone BL602:
## 2.63
## See https://gist.github.com/lupyuen/3ba0dc0789fd282bbfcf9dd5c3ff8908
```

Here's how we override the Default USB Device for PineDio Stack...

```bash
##  Tell the script to use /dev/ttyUSB1
export USB_DEVICE=/dev/ttyUSB1

##  Auto flash and test PineDio Stack BL604: LoRaWAN Test
remote-bl602/scripts/pinedio.sh

##  Auto test PineDio Stack BL604: Touchscreen Test
remote-bl602/scripts/pinedio2.sh
```

TODO: Fix the script to use the correct USB Device

# Upload Test Log

To __upload the Test Log__ to GitHub Release Notes...

```bash
##  Run the script for Auto Flash and Test, capture the Test Log
script -c remote-bl602/scripts/test.sh /tmp/release.log

##  Upload the Test Log to the GitHub Release Notes
remote-bl602/scripts/upload.sh
```

[(See the Test Log)](https://github.com/lupyuen/incubator-nuttx/releases/tag/pinedio-2022-05-10)

The `script` command runs the Auto Flash and Test Script `test.sh`, and captures the Test Log to `/tmp/release.log`.

Then we run this script to upload the Test Log to GitHub Release Notes...

-   [scripts/upload.sh](scripts/upload.sh)

The `upload.sh` script begins by calling the GitHub CLI to download the Auto-Generated GitHub Release Notes (populated by the GitHub Actions Build)...

```bash
##  Assumes the following files are present...
##  /tmp/release.log: Test Log
##  /tmp/release.tag: Release Tag (like pinedio-2022-05-10)

##  Preserve the Auto-Generated GitHub Release Notes.
##  Fetch the current GitHub Release Notes and extract the body text, like:
##  "Merge updates from master by @lupyuen in https://github.com/lupyuen/incubator-nuttx/pull/82"
gh release view \
    `cat /tmp/release.tag` \
    --json body \
    --jq '.body' \
    --repo lupyuen/incubator-nuttx \
    >/tmp/release.old
```

In case the script is run twice, we search for the Previous Test Log...

```bash
##  Find the position of the Previous Test Log, starting with "```"
cat /tmp/release.old \
    | grep '```' --max-count=1 --byte-offset \
    | sed 's/:.*//g' \
    >/tmp/previous-log.txt
prev=`cat /tmp/previous-log.txt`
```

And we remove the Previous Test Log, while preserving the Auto-Generated GitHub Release Notes...

```bash
##  If Previous Test Log exists, discard it
if [ "$prev" != '' ]; then
    cat /tmp/release.old \
        | head --bytes=$prev \
        >>/tmp/release2.log
else
    ##  Else copy the entire Release Notes
    cat /tmp/release.old \
        >>/tmp/release2.log
    echo "" >>/tmp/release2.log
fi
```

Just before adding the Test Log, we insert the Test Status...

```bash
##  Show the Test Status, like "All OK! BL602 has successfully joined the LoRaWAN Network"
grep "^===== " /tmp/release.log \
    | colrm 1 6 \
    >>/tmp/release2.log
```

Then we embed the Test Log, taking care of the Special Characters...

```bash
##  Enquote the Test Log without Carriage Return and Terminal Control Characters
##  https://stackoverflow.com/questions/17998978/removing-colors-from-output
echo '```text' >>/tmp/release2.log
cat /tmp/release.log \
    | tr -d '\r' \
    | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' \
    >>/tmp/release2.log
echo '```' >>/tmp/release2.log
```

Finally we call the GitHub CLI to upload the Auto-Generated GitHub Release Notes appended with the Test Log...

```bash
##  Upload the Test Log to the GitHub Release Notes
gh release edit \
    `cat /tmp/release.tag` \
    --notes-file /tmp/release2.log \
    --repo lupyuen/incubator-nuttx
```

# SPI Test Failure

Our Auto Test Scripts `test.sh` and `pinedio.sh` will check that the SX1262 LoRa Transceiver responds correctly to SPI Commands (like reading registers)...

```text
nsh> spi_test2
Get Status: received
  a2 22 
SX1262 Status is 2
Read Register 8: received
  a2 a2 a2 a2 80 
SX1262 Register 8 is 0x80
SX1262 is OK
```

This says that SX1262 Register 8 has value `0x80`, which is correct.

If we see this error on BL602...

```text
SX1262 Register 8 is 0x00
Error: SX1262 is NOT OK. Check the SPI connection
```

Check that the SX1262 Reset Pin is connected properly to the BL602 Reset Pin.

(Which is connected to SBC GPIO 3)

# LoRaWAN Test Failure

TODO

# Output Log for Upstream Build

Below is the log for the __Daily Upstream Build__ (without the LoRaWAN Stack)...

https://github.com/lupyuen/incubator-nuttx/releases/tag/upstream-2022-05-05

```text
pi@raspberrypi:~ $ ./upstream.sh
+ cd /home/pi/remote-bl602
+ git pull
Already up to date.
+ /home/pi/remote-bl602/scripts/test.sh
+ '[' '' == '' ']'
+ export BUILD_PREFIX=upstream
+ BUILD_PREFIX=upstream
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-05-05
+ BUILD_DATE=2022-05-05
+ '[' '' == '' ']'
+ export USB_DEVICE=/dev/ttyUSB0
+ USB_DEVICE=/dev/ttyUSB0
+ source /home/pi/.cargo/env
++ export PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
++ PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
+ set +x
----- Download the latest upstream NuttX build for 2022-05-05
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/upstream-2022-05-05/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp ~/remote-bl602
+ unzip -o nuttx.zip
Archive:  nuttx.zip
  inflating: nuttx
  inflating: nuttx.S
  inflating: nuttx.bin
  inflating: nuttx.config
  inflating: nuttx.hex
  inflating: nuttx.manifest
  inflating: nuttx.map
+ popd
~/remote-bl602
+ set +x
----- Enable GPIO 2 and 3
----- Set GPIO 2 and 3 as output
----- Set GPIO 2 to High (BL602 Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Toggle GPIO 3 High-Low-High (Reset BL602 again)
----- BL602 is now in Flashing Mode
----- Flash BL602 over USB UART with blflash
+ blflash flash /tmp/nuttx.bin --port /dev/ttyUSB0
[INFO  blflash::flasher] Start connection...
[TRACE blflash::flasher] 5ms send count 55
[TRACE blflash::flasher] handshake sent elapsed 394.944µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.553035396s 11.19KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.208118ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Erase flash addr: 10000 size: 135824
[INFO  blflash::flasher] Program flash... 1895df5ad1ea24dcab7c6ba5f86692424ce419d1da4e4c5b7dc06b4324d2cd59
[INFO  blflash::flasher] Program done 1.614955738s 82.18KiB/s
[INFO  blflash::flasher] Skip segment addr: 1f8000 size: 5671 sha256 matches
[INFO  blflash] Success
+ set +x
----- Set GPIO 2 to Low (BL602 Normal Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒gpio_pin_register: Registering /dev/gpio0
gpio_pin_register: Registering /dev/gpio1
gpint_enable: Disable the interrupt
gpio_pin_register: Registering /dev/gpio2
bl602_spi_setfrequency: frequency=400000, actual=0
bl602_spi_setbits: nbits=8
bl602_spi_setmode: mode=0

NuttShell (NSH) NuttX-10.3.0-RC1
nsh> uname -a
NuttX 10.3.0-RC1 fdef3a7b92 May  5 2022 02:23:24 risc-v bl602evb
nsh> ls /dev
/dev:
 console
 gpio0
 gpio1
 gpio2
 i2c0
 null
 spi0
 timer0
 zero
nsh>
----- Send command to BL602: lorawan_test
lorawan_test
nsh: lorawan_test: command not found
nsh>
===== Boot OK

+ read -p 'Press Enter to shutdown'
Press Enter to shutdown
```

# Output Log for Upstream Build with Crash Analysis

Below is the log for the __Daily Upstream Build__ with Crash Analysis (without the LoRaWAN Stack)...

```text
pi@raspberrypi:~/remote-bl602 $ sudo ./scripts/test.sh
+ '[' '' == '' ']'
+ export BUILD_PREFIX=upstream
+ BUILD_PREFIX=upstream
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-01-16
+ BUILD_DATE=2022-01-16
+ source /root/.cargo/env
++ case ":${PATH}:" in
++ export PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
++ PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
+ set +x
----- Download the latest upstream NuttX build for 2022-01-16
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/upstream-2022-01-16/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp /home/pi/remote-bl602
+ unzip -o nuttx.zip
Archive:  nuttx.zip
  inflating: nuttx
  inflating: nuttx.S
  inflating: nuttx.bin
  inflating: nuttx.config
  inflating: nuttx.hex
  inflating: nuttx.manifest
  inflating: nuttx.map
+ popd
/home/pi/remote-bl602
+ set +x
----- Enable GPIO 2 and 3
----- Set GPIO 2 and 3 as output
----- Set GPIO 2 to High (BL602 Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Toggle GPIO 3 High-Low-High (Reset BL602 again)
----- BL602 is now in Flashing Mode
----- Flash BL602 over USB UART with blflash
+ blflash flash /tmp/nuttx.bin --port /dev/ttyUSB0
[INFO  blflash::flasher] Start connection...
[TRACE blflash::flasher] 5ms send count 55
[TRACE blflash::flasher] handshake sent elapsed 233.442µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.551582797s 11.20KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.459475ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 10000 size: 85056 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 1f8000 size: 5671 sha256 matches
[INFO  blflash] Success
+ set +x
----- Set GPIO 2 to Low (BL602 Normal Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒
NuttShell (NSH) NuttX-10.2.0
nsh> irq_unexpected_isr: ERROR irq: 1
up_assert: Assertion failed at file:irq/irq_unexpectedisr.c line: 51 task: Idle Task
riscv_registerdump: EPC: deadbeee
riscv_registerdump: A0: 00000002 A1: 420146b0 A2: 42015140 A3: 4201481c
riscv_registerdump: A4: 420150d0 A5: 00000000 A6: 00000002 A7: 00000000
riscv_registerdump: T0: 00006000 T1: 00000003 T2: 41bd5488 T3: 00000064
riscv_registerdump: T4: 00000000 T5: 00000000 T6: c48af7e4
riscv_registerdump: S0: deadbeef S1: deadbeef S2: 420146b0 S3: 42014000
riscv_registerdump: S4: 42015000 S5: 42012510 S6: 00000001 S7: 23007000
riscv_registerdump: S8: 4201fa38 S9: 00000001 S10: 00000c40 S11: 42010510
riscv_registerdump: SP: 420126b0 FP: deadbeef TP: 005952e5 RA: deadbeef
riscv_dumpstate: sp:     420144b0
riscv_dumpstate: IRQ stack:
riscv_dumpstate:   base: 42012540
riscv_dumpstate:   size: 00002000
riscv_stackdump: 420144a0: 00001fe0 23011000 420144f0 230053a0 deadbeef deadbeef 23010ca4 00000033
riscv_stackdump: 420144c0: deadbeef 00000001 4201fa38 23007000 00000001 42012510 42015000 00000001
riscv_stackdump: 420144e0: 420125a8 42014000 42014500 230042e2 42014834 80007800 42014510 23001d3e
riscv_stackdump: 42014500: 420171c0 42014000 42014520 23001cdc deadbeef deadbeef 42014540 23000db4
riscv_stackdump: 42014520: deadbeef deadbeef deadbeef deadbeef deadbeef deadbeef 00000000 23000d04
riscv_dumpstate: sp:     420126b0
riscv_dumpstate: User stack:
riscv_dumpstate:   base: 42010530
riscv_dumpstate:   size: 00001fe0
riscv_showtasks:    PID    PRI      USED     STACK   FILLED    COMMAND
riscv_showtasks:   ----   ----      8088      8192    98.7%!   irq
riscv_dump_task:      0      0       436      8160     5.3%    Idle Task
riscv_dump_task:      1    100       516      8144     6.3%    nsh_main

----- Crash Analysis

----- Code Address 230053a0
23005396:       854e                    mv      a0,s3
23005398:       00000097                auipc   ra,0x0
2300539c:       c8c080e7                jalr    -884(ra) # 23005024 <riscv_stackdump>
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_assert.c:364
      if (CURRENT_REGS)
230053a0:       7f0a2783                lw      a5,2032(s4)
230053a4:       c399                    beqz    a5,230053aa <up_assert+0x274>
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_assert.c:366
          sp = CURRENT_REGS[REG_SP];
230053a6:       0087a983                lw      s3,8(a5)
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_assert.c:369

----- Address 230042e2
  up_assert(filename, linenum);
230042da:       00001097                auipc   ra,0x1
230042de:       e5c080e7                jalr    -420(ra) # 23005136 <up_assert>
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/libs/libc/assert/lib_assert.c:37
  exit(EXIT_FAILURE);
230042e2:       4505                    li      a0,1
230042e4:       ffffe097                auipc   ra,0xffffe
230042e8:       138080e7                jalr    312(ra) # 2300241c <exit>

230042ec <__errno>:
__errno():

----- Code Address 23001d3e

#else /* CONFIG_SMP */

int sched_lock(void)
{
23001d3e:       1141                    addi    sp,sp,-16
23001d40:       c422                    sw      s0,8(sp)
23001d42:       c226                    sw      s1,4(sp)
23001d44:       c606                    sw      ra,12(sp)
23001d46:       0800                    addi    s0,sp,16
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/sched/sched/sched_lock.c:228

----- Code Address 23001cdc
  /* Record the new "running" task.  g_running_tasks[] is only used by
   * assertion logic for reporting crashes.
   */

  g_running_tasks[this_cpu()] = this_task();
23001cdc:       420147b7                lui     a5,0x42014
23001ce0:       7fc7a703                lw      a4,2044(a5) # 420147fc <g_readytorun>
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/sched/irq/irq_dispatch.c:201
}
23001ce4:       40b2                    lw      ra,12(sp)
23001ce6:       4422                    lw      s0,8(sp)

----- Code Address 23000db4
   * point state and the establish the correct address environment before
   * returning from the interrupt.
   */

  if (regs != CURRENT_REGS)
23000db4:       7f04a503                lw      a0,2032(s1)
23000db8:       01250663                beq     a0,s2,23000dc4 <riscv_dispatch_irq+0x70>
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/chip/bl602_irq_dispatch.c:106
    {
#ifdef CONFIG_ARCH_FPU
      /* Restore floating point registers */

----- Code Address 23000d04
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_exception_common.S:120

  /* If context switch is needed, return a new sp     */

  mv         sp, a0
23000d04:       812a                    mv      sp,a0
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_exception_common.S:121
  REGLOAD    s0, REG_EPC(sp)     /* restore mepc      */
23000d06:       4402                    lw      s0,0(sp)
/home/runner/work/incubator-nuttx/incubator-nuttx/nuttx/nuttx/arch/risc-v/src/common/riscv_exception_common.S:122
  csrw       mepc, s0

----- Data Address 4201481c
4201481c g     O .bss   00000008 g_pendingtasks

----- Data Address 42012510
42012510 l    d  .bss   00000000 .bss
42012510 l     O .bss   00000008 g_idleargv
42012510 g       .bss   00000000 __bss_start

----- Data Address 42010510
42010510 l    d  .noinit        00000000 .noinit
42010510 g       .data  00000000 __boot2_pt_addr_end
42010510 g     O .noinit        00002000 g_idle_stack
42010510 g       .data  00000000 _data_run_end
42010510 g       .data  00000000 __boot2_pt_addr_start
42010510 g       .data  00000000 __boot2_flash_cfg_start
42010510 g       .data  00000000 __boot2_flash_cfg_end

----- Data Address 42012540
42012540 g     O .bss   00002000 g_intstackalloc

----- Data Address 42012510
42012510 l    d  .bss   00000000 .bss
42012510 l     O .bss   00000008 g_idleargv
42012510 g       .bss   00000000 __bss_start

----- Data Address 42014540
42014540 l     O .bss   00000080 g_uart0rxbuffer
42014540 g     O .bss   00000000 g_intstacktop

pi@raspberrypi:~/remote-bl602 $
```

# Output Log for Release Build

Below is the log for the __Release Build__ (includes the LoRaWAN Stack)...

https://github.com/lupyuen/incubator-nuttx/releases/tag/release-2022-04-27

```text
pi@raspberrypi:~ $ export BUILD_PREFIX=release; remote-bl602/scripts/test.sh &&
 read -p "Press Enter to shutdown" && sudo shutdown now
+ '[' release == '' ']'
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-04-27
+ BUILD_DATE=2022-04-27
+ source /home/pi/.cargo/env
++ export PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
++ PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
+ set +x
----- Download the latest release NuttX build for 2022-04-27
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/release-2022-04-27/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp ~
+ unzip -o nuttx.zip
Archive:  nuttx.zip
  inflating: nuttx
  inflating: nuttx.S
  inflating: nuttx.bin
  inflating: nuttx.board
  inflating: nuttx.config
  inflating: nuttx.hex
  inflating: nuttx.manifest
  inflating: nuttx.map
+ popd
~
+ set +x
----- Enable GPIO 2 and 3
----- Set GPIO 2 and 3 as output
----- Set GPIO 2 to High (BL602 Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Toggle GPIO 3 High-Low-High (Reset BL602 again)
----- BL602 is now in Flashing Mode
----- Flash BL602 over USB UART with blflash
+ blflash flash /tmp/nuttx.bin --port /dev/ttyUSB0
[INFO  blflash::flasher] Start connection...
[TRACE blflash::flasher] 5ms send count 55
[TRACE blflash::flasher] handshake sent elapsed 255.849µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.555431143s 11.18KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.185616ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Erase flash addr: 10000 size: 361712
[INFO  blflash::flasher] Program flash... 4284f227db04f3377f490bf455879ac200761a00cdfcbba9f0a7f28333c4e2d5
[INFO  blflash::flasher] Program done 4.301111592s 82.13KiB/s
[INFO  blflash::flasher] Skip segment addr: 1f8000 size: 5671 sha256 matches
[INFO  blflash] Success
+ set +x
----- Set GPIO 2 to Low (BL602 Normal Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒bme280_register: Failed to init: -134
bl602_bringup: ERROR: Failed to register BME280

NuttShell (NSH) NuttX-10.3.0-RC0
nsh>
----- Send command to BL602: lorawan_test
uname -a
NuttX 10.3.0-RC0 8afcc5bbf9-dirty Apr 27 2022 00:13:15 risc-v bl602evb
nsh> lorawan_test
init_entropy_pool
offset = 2204
temperature = 32.116600 Celsius
offset = 2204
temperature = 35.470142 Celsius
offset = 2204
temperature = 33.277439 Celsius
offset = 2204
temperature = 32.245583 Celsius

###### ===================================== ######

Application name   : lorawan_test
Application version: 1.2.0
GitHub base version: 5.0.0

###### ===================================== ######

init_event_queue
TimerInit:     0x42017408
TimerInit:     0x42017424
TimerInit:     0x42017440
TimerInit:     0x420174bc
TimerInit:     0x42017570
TimerInit:     0x4201758c
TimerInit:     0x420175a8
TimerInit:     0x420175c4
TODO: RtcGetCalendarTime
TODO: SX126xReset
init_gpio
DIO1 pintype before=5
init_gpio: change DIO1 to Trigger GPIO Interrupt on Rising Edge
gpio_ioctl: Requested pintype 8, but actual pintype 5
DIO1 pintype after=5
Starting process_dio1
init_spi
SX126xSetTxParams: power=22, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=, paLut=1
TimerInit:     0x42016508
TimerInit:     0x42016474
RadioSetModem
RadioSetModem
RadioSetPublicNetwork: public syncword=3444
RadioSleep
callout_handler: lock
process_dio1 started
process_dio1: event=0x42016530
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
RadioSetModem
RadioSetPublicNetwork: public syncword=3444
DevEui      : 4B-C1-5E-E7-37-7B-B1-5B
JoinEui     : 00-00-00-00-00-00-00-00
Pin         : 00-00-00-00

TimerInit:     0x42017060
TimerInit:     0x4201707c
TimerInit:     0x42016f40
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
TODO: RtcBkupRead
RadioSetChannel: freq=923400000
RadioSetTxConfig: modem=1, power=13, fdev=0, bandwidth=0, datarate=10, coderate=1, preambleLen=8, fixLen=0, crcOn=1, freqHopOn=0, hopPeriod=0, iqInverted=0, timeout=4000
RadioSetTxConfig: SpreadingFactor=10, Bandwidth=4, CodingRate=1, LowDatarateOptimize=0, PreambleLength=8, HeaderType=0, PayloadLength=255, CrcMode=1, InvertIQ=0
RadioStandby
RadioSetModem
SX126xSetTxParams: power=13, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
SecureElementRandomNumber: 0xcee1903f
RadioSend: size=23
00 00 00 00 00 00 00 00 00 5b b1 7b 37 e7 5e c1 4b 3f 90 dc e8 b4 45
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=23, CrcMode=1, InvertIQ=0
TimerStop:     0x42016508
TimerStart2:   0x42016508, 4000 ms
callout_reset: evq=0x42013010, ev=0x42016508

###### =========== MLME-Request ============ ######
######               MLME_JOIN               ######
###### ===================================== ######
STATUS      : OK
StartTxProcess
TimerInit:     0x42015954
TimerSetValue: 0x42015954, 42249 ms
OnTxTimerEvent: timeout in 42249 ms, event=0
TimerStop:     0x42015954
TimerSetValue: 0x42015954, 42249 ms
TimerStart:    0x42015954
TimerStop:     0x42015954
TimerStart2:   0x42015954, 42249 ms
callout_reset: evq=0x42013010, ev=0x42015954
handle_event_queue
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x42016508
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerSetValue: 0x42017424, 4988 ms
TimerStart:    0x42017424
TimerStop:     0x42017424
TimerStart2:   0x42017424, 4988 ms
callout_reset: evq=0x42013010, ev=0x42017424
TimerSetValue: 0x42017440, 5988 ms
TimerStart:    0x42017440
TimerStop:     0x42017440
TimerStart2:   0x42017440, 5988 ms
callout_reset: evq=0x42013010, ev=0x42017440
TODO: RtcGetCalendarTime
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
callout_handler: unlock
callout_handler: evq=0x42013010, ev=0x42017424
callout_handler: lock
handle_event_queue: ev=0x42017424
TimerStop:     0x42017424
RadioStandby
RadioSetChannel: freq=923400000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x42016474
TimerStart2:   0x42016474, 3000 ms
callout_reset: evq=0x42013010, ev=0x42016474
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_PREAMBLE_DETECTED
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_HEADER_VALID
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_DONE
TimerStop:     0x42016474
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerStop:     0x42017440
OnTxData

###### =========== MLME-Confirm ============ ######
STATUS      : OK
OnJoinRequest
###### ===========   JOINED     ============ ######

OTAA

DevAddr     :  011832DF


DATA RATE   : DR_2

TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
UplinkProcess
PrepareTxFrame: Transmit to LoRaWAN: Hi NuttX (9 bytes)
PrepareTxFrame: status=0, maxSize=11, currentSize=11
LmHandlerSend: Data frame
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioSetChannel: freq=923200000
RadioSetTxConfig: modem=1, power=13, fdev=0, bandwidth=0, datarate=9, coderate=1, preambleLen=8, fixLen=0, crcOn=1, freqHopOn=0, hopPeriod=0, iqInverted=0, timeout=4000
RadioSetTxConfig: SpreadingFactor=9, Bandwidth=4, CodingRate=1, LowDatarateOptimize=0, PreambleLength=8, HeaderType=0, PayloadLength=128, CrcMode=1, InvertIQ=0
RadioStandby
RadioSetModem
SX126xSetTxParams: power=13, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
RadioSend: size=22
40 df 32 18 01 00 01 00 01 d6 ef 78 3b 57 fa 20 ec a3 da 88 17 2a
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=22, CrcMode=1, InvertIQ=0
TimerStop:     0x42016508
TimerStart2:   0x42016508, 4000 ms
callout_reset: evq=0x42013010, ev=0x42016508

###### =========== MCPS-Request ============ ######
######           MCPS_UNCONFIRMED            ######
###### ===================================== ######
STATUS      : OK
PrepareTxFrame: Transmit OK
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x42016508
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerSetValue: 0x42017424, 980 ms
TimerStart:    0x42017424
TimerStop:     0x42017424
TimerStart2:   0x42017424, 980 ms
callout_reset: evq=0x42013010, ev=0x42017424
TimerSetValue: 0x42017440, 1988 ms
TimerStart:    0x42017440
TimerStop:     0x42017440
TimerStart2:   0x42017440, 1988 ms
callout_reset: evq=0x42013010, ev=0x42017440
TODO: RtcGetCalendarTime
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
callout_handler: unlock
callout_handler: evq=0x42013010, ev=0x42017424
callout_handler: lock
handle_event_queue: ev=0x42017424
TimerStop:     0x42017424
RadioStandby
RadioSetChannel: freq=923200000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x42016474
TimerStart2:   0x42016474, 3000 ms
callout_reset: evq=0x42013010, ev=0x42016474
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_TX_TIMEOUT
TimerStop:     0x42016474
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerStop:     0x42017440
TimerStop:     0x42017408
OnTxData

###### =========== MCPS-Confirm ============ ######
STATUS      : OK

###### =====   UPLINK FRAME        1   ===== ######

CLASS       : A

TX PORT     : 1
TX DATA     : UNCONFIRMED
48 69 20 4E 75 74 74 58 00

DATA RATE   : DR_3
U/L FREQ    : 923200000
TX POWER    : 0
CHANNEL MASK: 0003

TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
UplinkProcess
handle_event_queue: ev=0x42016530
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
UplinkProcess

===== All OK! BL602 has successfully joined the LoRaWAN Network

Press Enter to shutdown
```

# Output Log for PineDio Stack BL604 Build

Below is the log for the __PineDio Stack BL604 Build__ (includes the LoRaWAN Stack, ST7789 Display Driver, Touch Panel Driver, LVGL Test App)...

https://github.com/lupyuen/incubator-nuttx/releases/tag/pinedio-2022-05-05

```text
pi@raspberrypi:~ $ ./pinedio.sh
+ cd /home/pi/remote-bl602
+ git pull
Already up to date.
+ lsusb -v -s 1:3
+ grep bcdDevice
+ colrm 1 23
2.63
+ lsusb -v -s 1:4
+ grep bcdDevice
+ colrm 1 23
2.64
+ export USB_DEVICE=/dev/ttyUSB1
+ USB_DEVICE=/dev/ttyUSB1
+ /home/pi/remote-bl602/scripts/pinedio.sh
+ '[' '' == '' ']'
+ export BUILD_PREFIX=pinedio
+ BUILD_PREFIX=pinedio
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-05-05
+ BUILD_DATE=2022-05-05
+ '[' /dev/ttyUSB1 == '' ']'
+ source /home/pi/.cargo/env
++ export PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
++ PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
+ set +x
----- Download the latest pinedio NuttX build for 2022-05-05
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/pinedio-2022-05-05/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp ~/remote-bl602
+ unzip -o nuttx.zip
Archive:  nuttx.zip
  inflating: nuttx
  inflating: nuttx.S
  inflating: nuttx.bin
  inflating: nuttx.board
  inflating: nuttx.bringup
  inflating: nuttx.config
  inflating: nuttx.hex
  inflating: nuttx.manifest
  inflating: nuttx.map
+ popd
~/remote-bl602
+ set +x
----- Enable GPIO 5 and 6
----- Set GPIO 5 and 6 as output
----- Set GPIO 5 to High (BL602 Flashing Mode)
----- Toggle GPIO 6 High-Low-High (Reset BL602)
----- Toggle GPIO 6 High-Low-High (Reset BL602 again)
----- BL602 is now in Flashing Mode
----- Flash BL602 over USB UART with blflash
+ blflash flash /tmp/nuttx.bin --port /dev/ttyUSB1
[INFO  blflash::flasher] Start connection...
[TRACE blflash::flasher] 5ms send count 55
[TRACE blflash::flasher] handshake sent elapsed 297.388µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 4, 40, ad, b8, e3, 4c, b9, 7c, 15, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.559526151s 11.17KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.21273ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Erase flash addr: 10000 size: 504288
[INFO  blflash::flasher] Program flash... 2bea6e72b3247483532ea61fb9415a9f6718d50bb9e7ffa8992ed078185a8f3f
[INFO  blflash::flasher] Program done 6.002709982s 82.05KiB/s
[INFO  blflash::flasher] Skip segment addr: 1f8000 size: 5671 sha256 matches
[INFO  blflash] Success
+ set +x
----- Set GPIO 5 to Low (BL602 Normal Mode)
----- Toggle GPIO 6 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 6 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒gplh_enable: WARNING: pin9: Already detached
gplh_enable: WARNING: pin12: Already detached
gplh_enable: WARNING: pin19: Already detached
cst816s_register: path=/dev/input0, addr=21
cst816s_register: Driver registered

NuttShell (NSH) NuttX-10.3.0-RC0
nsh> uname -a
NuttX 10.3.0-RC0 4db8d2954d May  5 2022 08:58:49 risc-v bl602evb
nsh> ls /dev
/dev:
 console
 gpio10
 gpio12
 gpio14
 gpio15
 gpio19
 gpio20
 gpio21
 gpio3
 gpio9
 i2c0
 input0
 lcd0
 null
 spi0
 spitest0
 timer0
 urandom
 zero
nsh>
----- Send command to BL602: lorawan_test
lorawan_test
init_entropy_pool
offset = 2209
temperature = 22.055979 Celsius
offset = 2209
temperature = 26.957306 Celsius
offset = 2209
temperature = 25.667484 Celsius
offset = 2209
temperature = 25.667484 Celsius

###### ===================================== ######

Application name   : lorawan_test
Application version: 1.2.0
GitHub base version: 5.0.0

###### ===================================== ######

init_event_queue
TimerInit:     0x4201c76c
TimerInit:     0x4201c788
TimerInit:     0x4201c7a4
TimerInit:     0x4201c820
TimerInit:     0x4201c8d4
TimerInit:     0x4201c8f0
TimerInit:     0x4201c90c
TimerInit:     0x4201c928
TODO: RtcGetCalendarTime
TODO: SX126xReset
init_gpio
DIO1 pintype before=5
init_gpio: change DIO1 to Trigger GPIO gInterrupt on Rising Edge
plh_enable: WARNING: pin19: Already detached
DIO1 pintype after=8
Starting process_dio1
init_spi
SX126xSetTxParams: power=22, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
TimerInit:     0x4201b86c
TimerInit:     0x4201b7d8
RadioSetModem
RadioSetModem
RadioSetPublicNetwork: public syncword=3444
RadioSleep
callout_handler: lock
process_dio1 started
process_dio1: event=0x4201b894
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
TODO: EepromMcuReadBuffer
RadioSetModem
RadioSetPublicNetwork: public syncword=3444
DevEui      : 4B-C1-5E-E7-37-7B-B1-5B
JoinEui     : 00-00-00-00-00-00-00-00
Pin         : 00-00-00-00

TimerInit:     0x4201c3c4
TimerInit:     0x4201c3e0
TimerInit:     0x4201c2a4
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
TODO: RtcBkupRead
RadioSetChannel: freq=923200000
RadioSetTxConfig: modem=1, power=13, fdev=0, bandwidth=0, datarate=10, coderate=1, preambleLen=8, fixLen=0, crcOn=1, freqHopOn=0, hopPeriod=0, iqInverted=0, timeout=4000
RadioSetTxConfig: SpreadingFactor=10, Bandwidth=4, CodingRate=1, LowDatarateOptimize=0, PreambleLength=8, HeaderType=0, PayloadLength=255, CrcMode=1, InvertIQ=0
RadioStandby
RadioSetModem
SX126xSetTxParams: power=13, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
SecureElementRandomNumber: 0x2365edd0
RadioSend: size=23
00 00 00 00 00 00 00 00 00 5b b1 7b 37 e7 5e c1 4b d0 ed d6 02 42 41
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=23, CrcMode=1, InvertIQ=0
TimerStop:     0x4201b86c
TimerStart2:   0x4201b86c, 4000 ms
callout_reset: evq=0x420131a8, ev=0x4201b86c

###### =========== MLME-Request ============ ######
######               MLME_JOIN               ######
###### ===================================== ######
STATUS      : OK
StartTxProcess
TimerInit:     0x4201a90c
TimerSetValue: 0x4201a90c, 42249 ms
OnTxTimerEvent: timeout in 42249 ms, event=0
TimerStop:     0x4201a90c
TimerSetValue: 0x4201a90c, 42249 ms
TimerStart:    0x4201a90c
TimerStop:     0x4201a90c
TimerStart2:   0x4201a90c, 42249 ms
callout_reset: evq=0x420131a8, ev=0x4201a90c
handle_event_queue
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x4201b86c
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
TimerSetValue: 0x4201c788, 4988 ms
TimerStart:    0x4201c788
TimerStop:     0x4201c788
TimerStart2:   0x4201c788, 4988 ms
callout_reset: evq=0x420131a8, ev=0x4201c788
TimerSetValue: 0x4201c7a4, 5988 ms
TimerStart:    0x4201c7a4
TimerStop:     0x4201c7a4
TimerStart2:   0x4201c7a4, 5988 ms
callout_reset: evq=0x420131a8, ev=0x4201c7a4
TODO: RtcGetCalendarTime
callout_handler: unlock
callout_handler: evq=0x420131a8, ev=0x4201c788
callout_handler: lock
handle_event_queue: ev=0x4201c788
TimerStop:     0x4201c788
RadioStandby
RadioSetChannel: freq=923200000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x4201b7d8
TimerStart2:   0x4201b7d8, 3000 ms
callout_reset: evq=0x420131a8, ev=0x4201b7d8
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_PREAMBLE_DETECTED
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_HEADER_VALID
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_DONE
TimerStop:     0x4201b7d8
RadioOnDioIrq
RadioIrqProcess
RadioSleep
TimerStop:     0x4201c7a4
OnTxData

###### =========== MLME-Confirm ============ ######
STATUS      : OK
OnJoinRequest
###### ===========   JOINED     ============ ######

OTAA

DevAddr     :  00F76FBF


DATA RATE   : DR_2

TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
UplinkProcess
PrepareTxFrame: Transmit to LoRaWAN: Hi NuttX (9 bytes)
PrepareTxFrame: status=0, maxSize=11, currentSize=11
LmHandlerSend: Data frame
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioSetChannel: freq=923400000
RadioSetTxConfig: modem=1, power=13, fdev=0, bandwidth=0, datarate=9, coderate=1, preambleLen=8, fixLen=0, crcOn=1, freqHopOn=0, hopPeriod=0, iqInverted=0, timeout=4000
RadioSetTxConfig: SpreadingFactor=9, Bandwidth=4, CodingRate=1, LowDatarateOptimize=0, PreambleLength=8, HeaderType=0, PayloadLength=128, CrcMode=1, InvertIQ=0
RadioStandby
RadioSetModem
SX126xSetTxParams: power=13, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
RadioSend: size=22
40 bf 6f f7 00 00 01 00 01 34 9a 34 20 a6 ed 59 55 ae 23 55 11 70
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=22, CrcMode=1, InvertIQ=0
TimerStop:     0x4201b86c
TimerStart2:   0x4201b86c, 4000 ms
callout_reset: evq=0x420131a8, ev=0x4201b86c

###### =========== MCPS-Request ============ ######
######           MCPS_UNCONFIRMED            ######
###### ===================================== ######
STATUS      : OK
PrepareTxFrame: Transmit OK
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x4201b86c
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
TimerSetValue: 0x4201c788, 980 ms
TimerStart:    0x4201c788
TimerStop:     0x4201c788
TimerStart2:   0x4201c788, 980 ms
callout_reset: evq=0x420131a8, ev=0x4201c788
TimerSetValue: 0x4201c7a4, 1988 ms
TimerStart:    0x4201c7a4
TimerStop:     0x4201c7a4
TimerStart2:   0x4201c7a4, 1988 ms
callout_reset: evq=0x420131a8, ev=0x4201c7a4
TODO: RtcGetCalendarTime
callout_handler: unlock
callout_handler: evq=0x420131a8, ev=0x4201c788
callout_handler: lock
handle_event_queue: ev=0x4201c788
TimerStop:     0x4201c788
RadioStandby
RadioSetChannel: freq=923400000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x4201b7d8
TimerStart2:   0x4201b7d8, 3000 ms
callout_reset: evq=0x420131a8, ev=0x4201b7d8
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x4201b894
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_TX_TIMEOUT
TimerStop:     0x4201b7d8
RadioOnDioIrq
RadioIrqProcess
RadioSleep
TimerStop:     0x4201c7a4
TimerStop:     0x4201c76c
OnTxData

###### =========== MCPS-Confirm ============ ######
STATUS      : OK

###### =====   UPLINK FRAME        1   ===== ######

CLASS       : A

TX PORT     : 1
TX DATA     : UNCONFIRMED
48 69 20 4E 75 74 74 58 00

DATA RATE   : DR_3
U/L FREQ    : 923400000
TX POWER    : 0
CHANNEL MASK: 0003

TODO: EepromMcuWriteBuffer
TODO: EepromMcuWriteBuffer
UplinkProcess

===== All OK! BL602 has successfully joined the LoRaWAN Network

+ /home/pi/remote-bl602/scripts/pinedio2.sh
+ '[' '' == '' ']'
+ export BUILD_PREFIX=pinedio
+ BUILD_PREFIX=pinedio
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-05-05
+ BUILD_DATE=2022-05-05
+ '[' /dev/ttyUSB1 == '' ']'
+ source /home/pi/.cargo/env
++ export PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
++ PATH=/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/home/pi/.cargo/bin:/usr/lib/go-1.13.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
+ set +x
----- Enable GPIO 5 and 6
----- Set GPIO 5 and 6 as output
----- Set GPIO 5 to Low (BL602 Normal Mode)
----- Toggle GPIO 6 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 6 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒gplh_enable: WARNING: pin9: Already detached
gplh_enable: WARNING: pin12: Already detached
gplh_enable: WARNING: pin19: Already detached
cst816s_register: path=/dev/input0, addr=21
cst816s_register: Driver registered

NuttShell (NSH) NuttX-10.3.0-RC0
nsh> uname -a
NuttX 10.3.0-RC0 4db8d2954d May  5 2022 08:58:49 risc-v bl602evb
nsh> ls /dev
/dev:
 console
 gpio10
 gpio12
 gpio14
 gpio15
 gpio19
 gpio20
 gpio21
 gpio3
 gpio9
 i2c0
 input0
 lcd0
 null
 spi0
 spitest0
 timer0
 urandom
 zero
nsh>
----- Send command to BL602: lvgltest
lvgltest
tp_init: Opening /dev/input0
cst816s_open:

----- HELLO HUMAN: TOUCH PINEDIO STACK NOW
cst816s_poll_notify:
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=0, y=0
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       0
cst816s_get_touch_data:   y:       0
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: DOWN: id=0, touch=0, x=83, y=106
cst816s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   19
cst816s_get_touch_data:   x:      83
cst816s_get_touch_data:   y:       106
cst816s_get_touch_data:
cst816s_i2c_read:
bl602_i2c_transfer: i2c transfer success
bl602_i2c_transfer: i2c transfer success
cst816s_get_touch_data: Invalid touch data: id=9, touch=2, x=639, y=1688
cst816s_get_touch_data: UP: id=0, touch=2, x=83, y=106
cst16s_get_touch_data:   id:      0
cst816s_get_touch_data:   flags:   0c
cst816s_get_touch_data:   x:       83
cst816s_get_touch_data:   y:       106

===== All OK! BL604 has responded to touch

+ read -p 'Press Enter to shutdown'
Press Enter to shutdown
```
