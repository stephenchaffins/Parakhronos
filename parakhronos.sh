#!/bin/bash

# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins <schaffins>
# @Date:   2020-08-12T04:46:47-04:00
# @Email:  schaffins@jumpline.com
# @Project: Parakhronos
# @Filename: parakhronos.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-12T14:36:49-04:00
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Setting some basic variables just to get us started. This includes the list
# of users that will be used. A single user name can be used. This is ran with
# something like /parakhronos.sh USERNAME USERNAME2.
# -----------------------------------------------------------------------------

IFS=$'\n'
masteruserlist=( "$@" )
rand0pass=$(/bin/date +%N%s | base64 |cut -c -12)

# -----------------------------------------------------------------------------
# Some basic checks, for and to create directories and ensure things can get
# moved around/organized properly. This will also check for and grab the
# included scripts we will need.
# -----------------------------------------------------------------------------

mkdir -p /root/migration_scripts/
mkdir -p /var/log/parakhronos_logs/

# check for packaging script, remove it exists. Download anew.
if [[ -f /root/migration_scripts/pkhro_pkg.sh ]]; then
  rm -f /root/migration_scripts/pkhro_pkg.sh
elif [[ ! -f /root/migration_scripts/pkhro_pkg.sh ]]; then
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg.sh -O /root/migration_scripts/pkhro_pkg.sh
else
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg.sh -O /root/migration_scripts/pkhro_pkg.sh
fi

# check for restore script, remove it exists. Download anew.
if [[ -f /root/migration_scripts/pkhro_restore.sh ]]; then
  rm -f /root/migration_scripts/pkhro_restore.sh
elif [[ ! -f /root/migration_scripts/pkhro_restore.sh ]]; then
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore.sh -O /root/migration_scripts/pkhro_restore.sh
else
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore.sh -O /root/migration_scripts/pkhro_restore.sh
fi

# -----------------------------------------------------------------------------
# Find out what kind of server it is. VDS master, VDS client, or cpanel. Then
# kick off the appropriate package or restore script.
# -----------------------------------------------------------------------------

if [[ ! -f /usr/local/cpanel/cpanel ]] ; then
  for i in "${masteruserlist[@]}"
  do
    echo -e "\e[33m\e[1m Making $i root directory... \e[0m";sleep 1; echo
    eval mkdir -p "~$i/root/migration_scripts"
    echo -e "\e[33m\e[1m Copying script to $i root directory... \e[0m";sleep 1; echo
    eval cp -av /root/migration_scripts/pkhro_pkg.sh "~$i/root/migration_scripts/"
    echo -e "\e[33m\e[1m Chowning root directory to $i ownership... \e[0m";sleep 1; echo
    eval chown $i: -R "~$i/root/migration_scripts/"
    echo -e "\e[33m\e[1m Running pkhro_pkg.sh inside of $i VDS... \e[0m";sleep 1; echo
    su - $i -c 'cd /root/migration_scripts/; /bin/bash pkhro_pkg.sh'
    echo -e "\e[33m\e[1m Rsyncing $i to vmcp14... \e[0m";sleep 1; echo
    su - $i -c 'rm -rf /root/migration_scripts;'
  done
  #elif [[ ! -f /usr/local/cpanel/cpanel && ! -d /sphera ]]; then
  #  echo "This is a VDS User Account"
elif [[ -f /usr/local/cpanel/cpanel ]]; then
  for i in "${masteruserlist[@]}"
  do
    cpname=$(echo $i | cut -c -8)
    echo $cpname "$rand0pass" >> /var/log/mig_user_pass
    echo -e "\e[33m\e[1m Restoring account $i \e[0m";sleep 1; echo
    eval cd /root/migration_scripts/
    eval ./pkhro_restore.sh $i $cpname "$rand0pass"
    sleep 5;
    echo;
  done

  echo -e "\e[33m\e[1m COPY THESE PASSWORDS NOW!!! THEY EXIST NOWHERE ELSE. \e[0m";
  echo -e "\e[33m\e[1m IF YOU DONT SAVE THESE NOW, YOU WILL HAVE TO REGENERATE FOR ALL CUSTOMERS MIGRATED \e[0m";
  echo -e "\e[33m\e[1m These corresponding password is used with anything that has a password in cPanel. \e[0m";sleep 1; echo
  cat /var/log/mig_user_pass
  rm -f /var/log/mig_user_pass
  rm -f /root/pkhro_restore.sh
else
  echo "WHAT IS THIS SERVER?!"
fi

exit 0
