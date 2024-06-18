#!/usr/bin/env bash
## Background Task for Auto Flash and Test BL602

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

## Get the Home Assistant Token, copied from http://localhost:8123/profile/security
## token=xxxx
. $HOME/home-assistant-token.sh

## Default Build Prefix is "upstream"
if [ "$BUILD_PREFIX" == '' ]; then
  export BUILD_PREFIX=upstream
fi

## Get the Script Directory
SCRIPT_PATH="${BASH_SOURCE}"
SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"

## Wait for GitHub Release, then SSH to SBC for Flash and Test
function flash_and_test {

  ## Default Build Date is today (YYYY-MM-DD)
  if [ "$BUILD_DATE" == '' ]; then
    export BUILD_DATE=$(date +'%Y-%m-%d')
  fi

  ## If NuttX Build already downloaded, quit
  NUTTX_ZIP=/tmp/$BUILD_PREFIX-$BUILD_DATE-nuttx.zip
  if [ -e $NUTTX_ZIP ] 
  then
    return
  fi

  echo "----- Download the NuttX Build"
  wget -q \
    https://github.com/lupyuen/incubator-nuttx/releases/download/$BUILD_PREFIX-$BUILD_DATE/nuttx.zip \
    -O $NUTTX_ZIP \
    || true

  ## If build doesn't exist, quit
  FILESIZE=$(wc -c $NUTTX_ZIP | cut -d/ -f1)
  if [ "$FILESIZE" -eq "0" ]; then
    rm $NUTTX_ZIP
    return
  fi

  echo "----- Power Off the SBC"
  curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.pi_power_off"}' \
    http://localhost:8123/api/services/automation/trigger

  echo "----- Power On the SBC"
  curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.pi_power_on"}' \
    http://localhost:8123/api/services/automation/trigger

  echo "----- Wait for SBC to power on"
  sleep 30

  echo "----- SSH to SBC for BL602 Flash and Test"
  $SCRIPT_DIR/ssh.exp || true

  echo "----- Power Off the SBC"
  curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.pi_power_off"}' \
    http://localhost:8123/api/services/automation/trigger
  echo flash_and_test OK!
}

## Wait for GitHub Release, then SSH to SBC for Flash and Test
for (( ; ; ))
do
  flash_and_test
  sleep 600
done
echo Done!
