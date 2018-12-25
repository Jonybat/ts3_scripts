#!/bin/bash
#
### TeamSpeak 3 viewer generator
#
# Requires: curl, ts3wi

. /opt/ts3scripts/.secrets

cd "$TSVIEWER_DIR"

echo "<?php
session_start();
\$_SESSION['pubviewer']=true;
?>" > "$TSVIEWER_FULL.tmp"
curl -k "https://$TSVIEWER_DNS/ts3wi/tsviewpub-full.php?ip=$TSVIEWER_IP&skey=0&sid=3&showicons=right&bgcolor=ffffff&fontcolor=ffffff" >> "$TSVIEWER_FULL.tmp"

mv "$TSVIEWER_FULL.tmp" "$TSVIEWER_FULL"

sleep 5

echo "<?php
session_start();
\$_SESSION['pubviewer']=true;
?>" > "$TSVIEWER_MINI.tmp"
curl -k "https://$TSVIEWER_DNS/ts3wi/tsviewpub-mini.php?ip=$TSVIEWER_IP&skey=0&sid=3&showicons=right&bgcolor=transparent&fontcolor=EEE&linkcolor=DC9E3B&footcolor=AAA&height=200px" >> "$TSVIEWER_MINI.tmp"

mv "$TSVIEWER_MINI.tmp" "$TSVIEWER_MINI"

exit 0
