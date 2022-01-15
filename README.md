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
##  Install blflash for flashing BL602
cargo install blflash

##  Auto flash and test BL602
sudo scripts/test.sh
```

# Output Log

```text
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
----- Set GPIO 2 to Low (BL602 Non-Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- Set GPIO 2 to High (BL602 Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- TODO: Flash BL602 over USB UART with blflash
----- Set GPIO 2 to Low (BL602 Non-Flashing Mode)
----- Toggle GPIO 3 High-Low-High (Reset BL602)
----- TODO: Capture the BL602 output over USB UART
----- Disable GPIO 2
----- Disable GPIO 3
```
