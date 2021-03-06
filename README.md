## My TeamSpeak 3 scripts

This is a collection of scripts I use for my TeamSpeak 3 environment. Most of them are highly specific, but I still tried to make them as portable as I can.

---

### `clients_online.php`, `clients_list.php` and `server_message.php`

These PHP scripts use [ts3phpframework](https://github.com/planetteamspeak/ts3phpframework) to list the number of online clients, the names of connected clients and send a server message, respectively.

They require the following parameters that are fetched from the `.config.php` file: hostname, serverquery user, serverquery password, voice port and serverquery port. It also requires the server alias and instance number need to be provided as arguments 1 and 2. `server_message.php` takes the message as the third argument.

#### `.config.php` example:
```
<?php
$cfg["host_alias"] = "127.0.0.1";
$cfg["query_alias"] = 10011;
$cfg["voice_alias-instance"] = 9987;
$cfg["user_alias-instance"] = "username";
$cfg["pass_alias-instance"] = "password";
return $cfg;
```

#### Usage: `php clients_online.php "alias" "instance"`
#### Usage: `php clients_list.php "alias" "instance"`
#### Usage: `php server_message.php "alias" "instance" "Test message"`

---

### `ts3_messenger.sh`

Uses the above PHP scripts to send server messages to TeamSpeak 3 servers. Requires the same server alias and instance number to be provided as arguments 1 and 2. Has an optional third argument `--only-new` to send the server message only if there are new clients connected.

#### Usage: `./ts3_messenger.sh "alias" "instance" [--only-new] "Test message"`

---

### `ts3_viewer.sh`

Generates static PHP files from the tsviewpub page from [ts3wi](http://interface.ts-rent.de/ts3-webinterface/index.php), mainly to prevent serverquery flooding. Requires some global variables.

#### `.secrets` example:
```
TSVIEWER_DNS="my.domain.com"
TSVIEWER_IP="127.0.0.1"
TSVIEWER_DIR="/tmp"
TSVIEWER_FULL="tsviewer-full.php"
TSVIEWER_MINI="tsviewer-mini.php"
```

---

### `ts3_users_per_channel.sh`

Uses the files generated by the above script to create a colon separated table of channels and number of users. Requires extra global variable `TS3_UC_COUNT` to be set as the destination for the output of this script.

#### `.secrets` example:
```
TSVIEWER_DIR="/tmp"
TSVIEWER_FULL="tsviewer-full.php"
TS3_UC_COUNT="/tmp/ts3_users_per_channel.txt"
```

---
