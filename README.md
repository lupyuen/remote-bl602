# Flash and Test BL602 Remotely via a Linux Single-Board Computer

[(Follow the updates on Twitter)](https://twitter.com/MisterTechBlog/status/1481794711744823296)

This script runs on a Linux Single-Board Computer (SBC) to automagically Flash and Test BL602, with the Latest Daily Build of Apache NuttX OS.

The script sends the "`lorawan_test`" command to BL602 after booting, to test the LoRaWAN Stack.

If BL602 crashes, the script runs a Crash Analysis to show the RISC-V Disassembly of the addresses in the Stack Trace.

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
| GND    | GND      | Ground

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
----- Download the latest release NuttX build for 2022-01-17
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/release-2022-01-17/nuttx.zip -O /tmp/nuttx.zip
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
[TRACE blflash::flasher] handshake sent elapsed 270.388µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.575279962s 11.10KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.2155ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 10000 size: 379216 sha256 matches
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
SecureElementRandomNumber: 0xf49ca09d
RadioSend: size=23
00 00 00 00 00 00 00 00 00 5b b1 7b 37 e7 5e c1 4b 9d a0 1a b3 de 09
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

DevAddr     :  000978EE


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
40 ee 78 09 00 00 01 00 01 e0 5b b6 22 22 62 59 0d d4 6b ff cd 0e
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
U/L FREQ    : 923400000
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

----- All OK! BL602 has successfully joined the LoRaWAN Network
root@raspberrypi:/home/pi/remote-bl602#
```
