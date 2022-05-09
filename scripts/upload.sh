#!/usr/bin/env bash
## Upload Test Log to GitHub Release Notes. Assumes the following files are present...
## /tmp/release.log: Test Log
## /tmp/release.tag: Release Tag

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

rm -f /tmp/release2.log

##  Show the status
grep "^===== " /tmp/release.log \
    | colrm 1 6 \
    >>/tmp/release2.log

##  Enquote the log without Carriage Return and Terminal Control Characters
##  https://stackoverflow.com/questions/17998978/removing-colors-from-output
echo '```text' >>/tmp/release2.log
cat /tmp/release.log \
    | tr -d '\r' \
    | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' \
    >>/tmp/release2.log
echo '```' >>/tmp/release2.log

##  Upload the Test Log to the GitHub Release Notes
gh release edit \
    `cat /tmp/release.tag` \
    --notes-file /tmp/release2.log \
    --repo lupyuen/incubator-nuttx

##  Show the status
grep "^===== " /tmp/release.log
