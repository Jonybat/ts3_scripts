#!/bin/bash
#
### TeamSpeak 3 server messenger bash connector
#
# Requires: php, ts3 php scripts

. /opt/scripts/shlog.sh
. /opt/ts3scripts/.secrets

serverMessage="/opt/ts3scripts/server_message.php"
clientsOnline="/opt/ts3scripts/clients_online.php"
clientsList="/opt/ts3scripts/clients_list.php"

server="$1"
instance="$2"

statusFile="/tmp/ts3_messenger_status-$server-$instance.txt"
newFile="/tmp/ts3_messenger_new-$server-$instance.txt"
tmpFile="/tmp/ts3_messenger_tmp-$server-$instance.txt"

send_message (){
  message="$1"
  log="$2"
  # Avoid anti-flood protection
  sleep 5
  # Send the message
  result=$(php "$serverMessage" "$server" "$instance" "$message")
  shlog -s datestamp "$log"
}

case "$3" in
  '--only-new')
    # Shift $4 to $3
    shift
    message="$3"
    # Check if status file is empty
    statusCount=$(cat $statusFile 2>/dev/null | wc -l)
    if [[ $statusCount -eq 0 ]]; then
      # Output current clients list to status file
      php "$clientsList" "$server" "$instance" > $statusFile
      # Check count after update
      statusCount=$(cat $statusFile 2>/dev/null | wc -l)
      if [[ $statusCount -ne 0 ]]; then
	statusList=$(for line in `cat $statusFile`; do echo -n "$line "; done)
	# Send the message
	send_message "$message" "Sent to $statusCount client(s) ( $statusList) on $server server ($instance):\n $message"
      else
	shlog "No clients connected" -p nolog
	exit 2
      fi
    else
      # Output current clients list to tmp file
      php "$clientsList" "$server" "$instance" > $newFile
      # Check if current client list is empty
      newCount=$(cat $newFile 2>/dev/null | wc -l)
      if [[ $newCount -eq 0 ]]; then
	shlog -s datestamp "Clients are no longer connected to the server"
	cp -f $newFile $statusFile
      else
	# Check if files differ
	diff -q $statusFile $newFile
	if [[ $? -eq 1 ]]; then
	  # Save current clients in tmp file for later update of status file
	  cp -f $newFile $tmpFile
	  # Remove previous clients from current, <> used for exact matching
	  for line in $(cat $statusFile); do
	    sed -i "/\<$line\>/d" $newFile
	  done
	  # Update status file wirh current
	  mv -f $tmpFile $statusFile
	  # Check count after sed
	  newCount=$(cat $newFile 2>/dev/null | wc -l)
	  if [[ $newCount -ne 0 ]]; then
	    newList=$(for line in `cat $newFile`; do echo -n "$line "; done)
	    # Send the message
	    send_message "$message" "Sent to $newCount new client(s) ( $newList) on $server server ($instance):\n $message"
	  else
	    statusList=$(for line in `cat $statusFile`; do echo -n "$line "; done)
	    shlog -s datestamp "Connected clients ( $statusList) have already been notified"
	  fi
	else
	  shlog -s datestamp "Previous and current clients are the same, not sending message"
	fi
      fi
   fi
  ;;
  *)
    message="$3"
    # Check if there are clients online
    online_clients=$(php "$clientsOnline" "$server" "$instance")
    if [[ $online_clients -ne 0 ]]; then
      send_message "$message" "Sent to $online_clients client(s) on $server server ($instance):\n $message"
    else
      shlog "No clients connected" -p nolog
      exit 2
    fi
  ;;
esac

exit 0
