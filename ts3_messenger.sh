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
statusFile="/tmp/ts3_messenger_status.txt"
newFile="/tmp/ts3_messenger_new.txt"
tmpFile="/tmp/ts3_messenger_tmp.txt"

send_backup (){
  # Avoid anti-flood protection
  sleep 5
  php "$serverMessage" "backup" "$INSTANCE_BACKUP" "$1"
}

case "$1" in
  local)
    php "$message_local" "local" "$INSTANCE_LOCAL" "$2"
    shlog -s datestamp "Sent to local:\n $2"
    ;;

  backup)
    case "$2" in
      '--only-new')
        # Shift $3 to $2
        shift
        # Check if status file is empty
        statusCount=$(cat $statusFile 2>/dev/null | wc -l)
        if [[ $statusCount -eq 0 ]]; then
          # Output current clients list to status file
          php "$clientsList" "backup" "$INSTANCE_BACKUP" > $statusFile
          # Check count after update
          statusCount=$(cat $statusFile 2>/dev/null | wc -l)
          if [[ $statusCount -ne 0 ]]; then
            # Send the message
            send_backup "$2"
            statusList=$(for line in `cat $statusFile`; do echo -n "$line "; done)
            shlog -s datestamp "Sent to $statusCount client(s) ( $statusList) on backup server:\n $2"
          else
            shlog "No clients connected" -p nolog
            exit 2
          fi
        else
          # Output current clients list to tmp file
          php "$clientsList" "backup" "$INSTANCE_BACKUP" > $newFile
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
                # Send the message
                send_backup "$2"
                newList=$(for line in `cat $newFile`; do echo -n "$line "; done)
                shlog -s datestamp "Sent to $newCount new client(s) ( $newList) on backup server:\n $2"
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
        # Check if there are clients online
        online_backup=$(php "$clientsOnline" "backup" "$INSTANCE_BACKUP")
        if [[ $online_backup -ne 0 ]]; then
         # Send the message
         send_backup "$2"
         shlog -s datestamp "Sent to $online_backup client(s) on backup server:\n $2"
        else
          shlog "No clients connected" -p nolog
          exit 2
        fi
        ;;
    esac
    ;;

  *)
    echo "Usage: $0 {local|backup} 'message'"
    exit 1
    ;;
esac

exit 0
