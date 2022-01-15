# Flash and Test BL602 Remotely via a Linux Single-Board Computer

[(Follow the updates on Twitter)](https://twitter.com/MisterTechBlog/status/1481794711744823296)

This script runs on a Linux Single-Board Computer (SBC) to automagically Flash and Test BL602, with the latest upstream build of Apache NuttX OS.

See [scripts/test.sh](scripts/test.sh)

NuttX Daily Builds are done by GitHub Actions. [(See this)](https://github.com/lupyuen/incubator-nuttx/blob/master/.github/workflows/bl602.yml)

Why are we doing this?

1.  Could be useful for Release Testing of NuttX OS on real hardware

1.  I write articles about NuttX OS. I need to pick the latest stable build of NuttX OS for testing the NuttX code in my articles. [(See this)](https://lupyuen.github.io/articles/book#nuttx-on-bl602)

# Run The Script

Connect SBC to to BL602 like so...

| SBC    | BL602    | Function
| -------|----------|----------
| GPIO 2 | GPIO 8   | Flashing Mode
| GPIO 3 | GPIO RST | Reset

To run it...

```bash
##  Install rustup as superuser, select default option
sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh

##  Install blflash as superuser for flashing BL602
sudo ~root/.cargo/bin/cargo install blflash

##  Auto flash and test BL602 as superuser
sudo scripts/test.sh
```

# Output Log

```text
+ source /root/.cargo/env
++ case ":${PATH}:" in
++ export PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
++ PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
+ set +x
----- Download the latest Upstream NuttX Release
++ date +%Y-%m-%d
+ wget -q https://github.com/lupyuen/incubator-nuttx/releases/download/upstream-2022-01-15/nuttx.zip -O /tmp/nuttx.zip
+ pushd /tmp
/tmp /home/pi/remote-bl602
+ unzip -o nuttx.zip
Archive:  nuttx.zip
  inflating: nuttx
  inflating: nuttx.S
  inflating: nuttx.bin
  inflating: nuttx.hex
  inflating: nuttx.manifest
  inflating: nuttx.map
+ popd
/home/pi/remote-bl602
+ set +x
----- Enable GPIO 2
----- Enable GPIO 3
----- Set GPIO 2 and 3 as output
----- Set GPIO 2 to High (BL602 Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- BL602 is now in Flashing Mode
----- Flash BL602 over USB UART with blflash
+ blflash flash /tmp/nuttx.bin --port /dev/ttyUSB0
[INFO  blflash::flasher] Start connection...
[TRACE blflash::flasher] 5ms send count 55
[TRACE blflash::flasher] handshake sent elapsed 295.475µs
[INFO  blflash::flasher] Connection Succeed
[INFO  blflash] Bootrom version: 1
[TRACE blflash] Boot info: BootInfo { len: 14, bootrom_version: 1, otp_info: [0, 0, 0, 0, 3, 0, 0, 0, 61, 9d, c0, 5, b9, 18, 1d, 0] }
[INFO  blflash::flasher] Sending eflash_loader...
[INFO  blflash::flasher] Finished 2.552984016s 11.20KiB/s
[TRACE blflash::flasher] 5ms send count 500
[TRACE blflash::flasher] handshake sent elapsed 5.204491ms
[INFO  blflash::flasher] Entered eflash_loader
[INFO  blflash::flasher] Skip segment addr: 0 size: 47504 sha256 matches
[INFO  blflash::flasher] Skip segment addr: e000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: f000 size: 272 sha256 matches
[INFO  blflash::flasher] Skip segment addr: 10000 size: 76832 sha256 matches
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
nsh> up_assert: Assertion failed at file:irq/irq_unexpectedisr.c line: 51 task: Idle Task
riscv_registerdump: EPC: deadbeee
riscv_registerdump: A0: 00000002 A1: 420146b0 A2: 42015140 A3: 4201481c
riscv_registerdump: A4: 420150d0 A5: 00000000 A6: 00000002 A7: 00000003
riscv_registerdump: T0: 00006000 T1: 00000000 T2: 41bd5488 T3: 00000037
riscv_registerdump: T4: 00000000 T5: 00000000 T6: 8672c84c
riscv_registerdump: S0: deadbeef S1: deadbeef S2: 420146b0 S3: 42014000
riscv_registerdump: S4: 42012510 S5: 42015000 S6: 00000001 S7: 23007000
riscv_registerdump: S8: 4201fa38 S9: 00000001 S10: 00000c20 S11: 42010510
riscv_registerdump: SP: 420126b0 FP: deadbeef TP: 025200a4 RA: deadbeef
riscv_dumpstate: sp:     420144b0
riscv_dumpstate: IRQ stack:
riscv_dumpstate:   base: 42012540
riscv_dumpstate:   size: 00002000
riscv_stackdump: 420144a0: 00001fe0 23010000 420144f0 23004d9c deadbeef deadbeef 2300f7b0 00000033
riscv_stackdump: 420144c0: deadbeef 00000001 4201fa38 23007000 00000001 42015000 42012510 00000001
riscv_stackdump: 420144e0: 420125a8 42014000 42014500 23003ff4 deadbeef deadbeef 42014510 23001c7a
riscv_stackdump: 42014500: deadbeef 42014000 42014520 23001c34 deadbeef deadbeef 42014540 23000d8c
riscv_stackdump: 42014520: deadbeef deadbeef deadbeef deadbeef deadbeef deadbeef 00000000 23000d04
riscv_dumpstate: sp:     420126b0
riscv_dumpstate: User stack:
riscv_dumpstate:   base: 42010530
riscv_dumpstate:   size: 00001fe0
riscv_showtasks:    PID    PRI      USED     STACK   FILLED    COMMAND
riscv_showtasks:   ----   ----      8088      8192    98.7%!   irq
riscv_dump_task:      0      0       404      8160     4.9%    Idle Task
riscv_dump_task:      1    100       500      8144     6.1%    nsh_main

----- TODO: Record the BL602 Output for Crash Analysis
----- Disable GPIO 2
----- Disable GPIO 3
```
