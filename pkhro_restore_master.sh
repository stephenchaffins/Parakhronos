#!/bin/bash

# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins <schaffins>
# @Date:   2017-02-28T13:48:19-05:00
# @Email:  schaffins@jumpline.com
# @Project: Parakhronos
# @Filename: vds2cp_restore_master.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-12T06:10:11-04:00
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# rsync the files to vmcp14 / root
# -----------------------------------------------------------------------------

IFS=$'\n'
cpusrs=( "$@" )

if [ ! -f /root/pkhro_restore.sh ]
then
wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore.sh; chmod 755 pkhro_restore.sh
fi

for i in "${cpusrs[@]}"
do
  cpname=$(echo $i | cut -c -8)
  prsswoad=$(/bin/date +%N%s | base64 |cut -c -12)
  echo $i $cpname "$prsswoad" >> /var/log/mig_user_pass
  echo -e "\e[33m\e[1m Restoring account $i \e[0m";sleep 1; echo
  eval cd /root/
  eval ./pkhro_restore.sh $i $cpname "$prsswoad"
  sleep 20;
  echo;
  echo;
done

echo -e "\e[33m\e[1m COPY THESE PASSWORDS NOW!!! THEY EXIST NOWHERE ELSE. IF YOU DONT SAVE THESE NOW, YOU WILL HAVE TO REGENERATE FOR ALL CUSTOMERS MIGRATED $i \e[0m";sleep 1; echo
cat /var/log/mig_user_pass
rm -f /var/log/mig_user_pass

exit 0
