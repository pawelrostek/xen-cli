#!/bin/bash

# xe pool-list
POOL_ID=`xe pool-list |grep "uuid ( RO)" | cut -d ":" -f 2 | tr -d '[:space:]'`

echo -e "\e[32;1mEnable autostart VM's in POOL ID: $POOL_ID\e[0m"
xe pool-param-set uuid=${POOL_ID} other-config:auto_poweron=true

echo -e "\nSelect one of VM:"
# xe vm-list 
oldIFS="$IFS"
IFS=$'\n'

LIST=(`xe vm-list |grep -P "(name-label|uuid)" | perl -pe 's/^uuid.+: (.+)\n/\1|/' | perl -pe 's/\|.+name-label.+?: /|/'`)

select id in $(echo "${LIST[*]}" | cut -d '|' -f 2-); do
  if [[ ( ! "$REPLY" =~ ^[0-9]+$ ) || ( "$REPLY" =~ ^0 ) ]]; then
    continue;
  fi                                                                                                                                                                    
                                                                                                                                                                        
  REPLY=$(( $REPLY - 1 ))                                                                                                                                               
  REPLY_ID=$(echo ${LIST[$REPLY]} | cut -d '|' -f 1)                                                                                                                    
  REPLY_NAME=$(echo ${LIST[$REPLY]} | cut -d '|' -f 2)
  if [[ "$REPLY_ID" != "" ]]; then
        break; 
  fi
done
IFS="$oldIFS"


echo -e "\nSet autostart \e[1mVM \e[32m${REPLY_NAME}\e[0m (${REPLY_ID})"
read -p "Are you sure? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        xe vm-param-set uuid=${REPLY_ID} other-config:auto_poweron=true
        echo -e "\nFINISH."
fi
