#!/bin/bash
#
### TS3 users per channel viewer scrapper
#
# Requires: xidel, ts3wi

. /opt/ts3scripts/.secrets

htmlFile="$TSVIEWER_DIR/$TSVIEWER_FULL"
countFile="$TS3_UC_COUNT"
echo -n "" > "$countFile"

channels=$(/usr/bin/xidel --silent --output-format=adhoc --html $htmlFile --xpath "//div[@class='channame']/a/text()" | grep -Ev "DOCTYPE|html|body|Group|Training|Ranking|Arena/Raid/Dungeon|~" | sed 's/ (.*//g')
while read -r channel; do
  echo "$channel:0" >> $countFile
done <<< "$channels"

users=$(/usr/bin/xidel --html $htmlFile --silent --output-format=adhoc --xpath "//div[@class='clientnick']/text()")
while read -r user; do
  prevCounter=1
  usedChannel=$(/usr/bin/xidel --html $htmlFile --silent --output-format=adhoc --xpath "//div[contains(text(), '$user')]/preceding::div[@class='channame'][$prevCounter]/a/text()" | sed 's/ (.*//g')
  while [[ $usedChannel =~ Group|Training|Ranking|Arena ]]; do
    prevCounter=$((prevCounter+1))
    usedChannel=$(/usr/bin/xidel --html $htmlFile --silent --output-format=adhoc --xpath "//div[contains(text(), '$user')]/preceding::div[@class='channame'][$prevCounter]/a/text()" | sed 's/ (.*//g')
  done
  while IFS=':' read -r channel userCount; do
    if [[ "$usedChannel" == "$channel" ]]; then
      userCount=$((userCount+1))
    fi
    sed -i "s|$channel.*|$channel:$userCount|g" "$countFile" 
  done < "$countFile"
done <<< "$users"

exit 0
