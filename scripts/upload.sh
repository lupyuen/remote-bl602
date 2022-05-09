#!/usr/bin/env bash
## Upload Test Log to GitHub Release Notes. Assumes the following files are present...
## /tmp/release.log: Test Log
## /tmp/release.tag: Release Tag

set -e  ##  Exit when any command fails
set -x  ##  Echo commands

rm -f /tmp/release2.log

##  Show the status
grep "^===== " /tmp/release.log >>/tmp/release2.log

##  Enquote the log
echo '```text' >>/tmp/release2.log
cat /tmp/release.log >>/tmp/release2.log
echo '```' >>/tmp/release2.log

cp /tmp/release2.log /tmp/release.log

##  Upload the Test Log to the Release Notes
gh release edit \
    `cat /tmp/release.tag` \
    --notes-file /tmp/release.log \
    --repo lupyuen/incubator-nuttx
