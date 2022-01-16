# Flash and Test BL602 Remotely via a Linux Single-Board Computer

[(Follow the updates on Twitter)](https://twitter.com/MisterTechBlog/status/1481794711744823296)

This script runs on a Linux Single-Board Computer (SBC) to automagically Flash and Test BL602, with the Latest Daily Build of Apache NuttX OS.

The script sends the "`lorawan_test`" command to BL602 after booting, to test the LoRaWAN Stack.

See [scripts/test.sh](scripts/test.sh)

NuttX Daily Builds are done by GitHub Actions...

-  [Daily Upstream Build](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602.yml) (Without the LoRaWAN Stack)

-  [Release Build](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602-commit.yml) (Includes the LoRaWAN Stack)

Why are we doing this?

1.  Could be useful for Release Testing of NuttX OS on real hardware

1.  By testing the LoRaWAN Stack on NuttX, we can be sure that GPIO Input / Output / Interrupts, SPI, Timers, Message Queues, PThreads and Strong Random Number Generator are all working

1.  I write articles about NuttX OS. I need to pick the latest stable build of NuttX OS for testing the NuttX code in my articles. [(See this)](https://lupyuen.github.io/articles/book#nuttx-on-bl602)

# Run The Script

Connect SBC to to BL602 like so...

| SBC    | BL602    | Function
| -------|----------|----------
| GPIO 2 | GPIO 8   | Flashing Mode
| GPIO 3 | GPIO RST | Reset

For auto-testing LoRaWAN, also connect BL602 to SX1262 as described below...

- ["Connect SX1262"](https://lupyuen.github.io/articles/spi2#connect-sx1262)

To run the flash and test script for the __Daily Upstream Build__ (without LoRaWAN)...

```bash
##  Install rustup as superuser, select default option
sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh

##  Install blflash as superuser for flashing BL602
sudo ~root/.cargo/bin/cargo install blflash

##  Download the flash and test script
git clone --recursive https://github.com/lupyuen/remote-bl602/
cd remote-bl602

##  Auto flash and test BL602 as superuser
sudo scripts/test.sh
```

(See the output log below)

To run the flash and test script for the __Release Build__ (includes LoRaWAN)...

```bash
##  Run shell as superuser, because we will be updating the environment variables
sudo bash

##  Tell the script to download the Release Build (instead of the Upstream Build)
export BUILD_PREFIX=release

##  Auto flash and test BL602
./scripts/test.sh
```

(See the output log below)

# Output Log for Upstream Build

Below is the log for the __Daily Upstream Build__ (without the LoRaWAN Stack)...

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
[TRACE blflash::flasher] handshake sent elapsed 277.925µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.559564146s 11.17KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.227105ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Erase flash addr: 10000 size: 85056
[INFO  blflash::flasher] Program flash... 1a406e1565a7c484e086d52642fea4ac58183218f238455ed091cb1a2a4aeb1b
[INFO  blflash::flasher] Program done 1.019176383s 81.51KiB/s
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
riscv_registerdump: T0: 00006000 T1: 00000003 T2: 41bd5688 T3: 00000064
riscv_registerdump: T4: 00000000 T5: 00000000 T6: c48af7e4
riscv_registerdump: S0: deadbeef S1: deadbeef S2: 420146b0 S3: 42014000
riscv_registerdump: S4: 42015000 S5: 42012510 S6: 00000001 S7: 23007000
riscv_registerdump: S8: 4201fa38 S9: 00000001 S10: 00000c40 S11: 42010510
riscv_registerdump: SP: 420126b0 FP: deadbeef TP: 005812e5 RA: deadbeef
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
riscv_showtasks:   ----   ----      8088      8192    98.7%!  irq
riscv_dump_task:      0     0       436      8160     5.3%    Idle Task
riscv_dump_task:      1    100       516      8144     6.3%    nsh_main

----- Send command to BL602: lorawan_test

----- TODO: Record the BL602 Output for Crash Analysis
pi@raspberrypi:~/remote-bl602 $
```

# Output Log for Release Build

Below is the log for the __Release Build__ (includes the LoRaWAN Stack)...

```text
pi@raspberrypi:~/remote-bl602 $ sudo bash
root@raspberrypi:/home/pi/remote-bl602# export BUILD_PREFIX=release; ./scripts/test.sh
+ '[' release == '' ']'
+ '[' '' == '' ']'
++ date +%Y-%m-%d
+ export BUILD_DATE=2022-01-16
+ BUILD_DATE=2022-01-16
+ source /root/.cargo/env
++ case ":${PATH}:" in
+ set +x
----- Download the latest release NuttX build for 2022-01-16
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/release-2022-01-16/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp /home/pi/remote-bl602
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
[TRACE blflash::flasher] handshake sent elapsed 302.868µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.559899883s 11.17KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.19733ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 10000 size: 379200 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 1f8000 size: 5671 sha256 matches
[INFO  blflash] Success
+ set +x
----- Set GPIO 2 to Low (BL602 Normal Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- BL602 is now in Normal Mode
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Here is the BL602 Output...
▒
NuttShell (NSH) NuttX-10.2.0-RC0
nsh>
----- Send command to BL602: lorawan_test
lorawan_test

###### ===================================== ######

Application name   : lorawan_test
Application version: 1.2.0
GitHub base version: 5.0.0

###### ===================================== ######

init_event_queue
TimerInit:     0x4201682c
callout_handler: lock
TimerInit:     0x42016848
TimerInit:     0x42016864
TimerInit:     0x420168c8
TimerInit:     0x4201695c
TimerInit:     0x42016978
TimerInit:     0x42016994
TimerInit:     0x420169b0
TODO: RtcGetCalendarTime
TODO: SX126xReset
init_gpio
DIO1 pintype before=5
init_gpio: change DIO1 to Trigger GPIO Interrupt on Rising Edge
gpio_ioctl: Requested pintype 8, but actual pintype 5
DIO1 pintype after=5
Starting process_dio1
process_dio1 started
process_dio1: event=0x42015ab8
init_spi
SX126xSetTxParams: power=22, rampTime=7
SX126xSetPaConfig: paDutyCycle=4, hpMax=7, deviceSel=0, paLut=1
TimerInit:     0x420179fc
TimerInit:     0x42017b2c
RadioSetModem
RadioSetModem
RadioSetPublicNetwork: public syncword=3444
RadioSleep
DIO1 add event
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

TimerInit:     0x42016484
TimerInit:     0x420164a0
TimerInit:     0x4201645c
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
SecureElementRandomNumber: 0x13e7c3db
RadioSend: size=23
00 00 00 00 00 00 00 00 00 5b b1 7b 37 e7 5e c1 4b db c3 9c ac 19 29
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=23, CrcMode=1, InvertIQ=0
TimerStop:     0x420179fc
TimerStart2:   0x420179fc, 4000 ms
callout_reset: evq=0x42017b48, ev=0x420179fc

###### =========== MLME-Request ============ ######
######               MLME_JOIN               ######
###### ===================================== ######
STATUS      : OK
StartTxProcess
TimerInit:     0x420154c0
TimerSetValue: 0x420154c0, 42249 ms
OnTxTimerEvent: timeout in 42249 ms, event=0
TimerStop:     0x420154c0
TimerSetValue: 0x420154c0, 42249 ms
TimerStart:    0x420154c0
TimerStop:     0x420154c0
TimerStart2:   0x420154c0, 42249 ms
callout_reset: evq=0x42017b48, ev=0x420154c0
handle_event_queue
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x420179fc
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerSetValue: 0x42016848, 4988 ms
TimerStart:    0x42016848
TimerStop:     0x42016848
TimerStart2:   0x42016848, 4988 ms
callout_reset: evq=0x42017b48, ev=0x42016848
TimerSetValue: 0x42016864, 5988 ms
TimerStart:    0x42016864
TimerStop:     0x42016864
TimerStart2:   0x42016864, 5988 ms
callout_reset: evq=0x42017b48, ev=0x42016864
TODO: RtcGetCalendarTime
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
callout_handler: unlock
callout_handler: evq=0x42017b48, ev=0x42016848
callout_handler: lock
handle_event_queue: ev=0x42016848
TimerStop:     0x42016848
RadioStandby
RadioSetChannel: freq=923400000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x42017b2c
TimerStart2:   0x42017b2c, 3000 ms
callout_reset: evq=0x42017b48, ev=0x42017b2c
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_PREAMBLE_DETECTED
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_HEADER_VALID
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_DONE
TimerStop:     0x42017b2c
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerStop:     0x42016864
OnTxData

###### =========== MLME-Confirm ============ ######
STATUS      : OK
OnJoinRequest
###### ===========   JOINED     ============ ######

OTAA

DevAddr     :  004E60A6


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
40 a6 60 4e 00 00 01 00 01 fe 4f b0 c0 4a 0f bd c5 15 c0 f5 74 d8
RadioSend: PreambleLength=8, HeaderType=0, PayloadLength=22, CrcMode=1, InvertIQ=0
TimerStop:     0x420179fc
TimerStart2:   0x420179fc, 4000 ms
callout_reset: evq=0x42017b48, ev=0x420179fc

###### =========== MCPS-Request ============ ######
######           MCPS_UNCONFIRMED            ######
###### ===================================== ######
STATUS      : OK
PrepareTxFrame: Transmit OK
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_TX_DONE
TimerStop:     0x420179fc
TODO: RtcGetCalendarTime
TODO: RtcBkupRead
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerSetValue: 0x42016848, 980 ms
TimerStart:    0x42016848
TimerStop:     0x42016848
TimerStart2:   0x42016848, 980 ms
callout_reset: evq=0x42017b48, ev=0x42016848
TimerSetValue: 0x42016864, 1988 ms
TimerStart:    0x42016864
TimerStop:     0x42016864
TimerStart2:   0x42016864, 1988 ms
callout_reset: evq=0x42017b48, ev=0x42016864
TODO: RtcGetCalendarTime
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
callout_handler: unlock
callout_handler: evq=0x42017b48, ev=0x42016848
callout_handler: lock
handle_event_queue: ev=0x42016848
TimerStop:     0x42016848
RadioStandby
RadioSetChannel: freq=923200000
RadioSetRxConfig
RadioStandby
RadioSetModem
RadioSetRxConfig done
RadioRx
TimerStop:     0x42017b2c
TimerStart2:   0x42017b2c, 3000 ms
callout_reset: evq=0x42017b48, ev=0x42017b2c
RadioOnDioIrq
RadioIrqProcess
DIO1 add event
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
IRQ_RX_TX_TIMEOUT
TimerStop:     0x42017b2c
RadioOnDioIrq
RadioIrqProcess
RadioSleep
DIO1 add event
TimerStop:     0x42016864
TimerStop:     0x4201682c
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
handle_event_queue: ev=0x42015ab8
RadioOnDioIrq
RadioIrqProcess
RadioOnDioIrq
RadioIrqProcess
UplinkProcess

----- TODO: Record the BL602 Output for Crash Analysis
root@raspberrypi:/home/pi/remote-bl602#
```
