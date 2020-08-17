#!/bin/bash

# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins <schaffins>
# @Date:   2020-08-12T04:46:47-04:00
# @Email:  schaffins@jumpline.com
# @Project: Parakhronos
# @Filename: parakhronos.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-17T00:21:44-04:00
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Setting basic variables and functions to get started. This includes a list
# of users that will be used. A single user name can be used. This is ran with
# something like /parakhronos.sh USERNAME USERNAME2.
# -----------------------------------------------------------------------------

IFS=$'\n'
masteruserlist=( "$@" )
rand0pass=$(/bin/date +%N%s | openssl enc -base64 |cut -c -12)

# function to kill the script if theres a Catastrophic Failure.
function dye()
{
   echo -e "\e[1m\e[41m Try Again! \e[0m"
   kill -s TERM $TOP_PID
}


# -----------------------------------------------------------------------------
# Some basic checks to create directories and files necessary to
# ensure things can get started. This will check for and grab the included
# scripts we will need.
# -----------------------------------------------------------------------------

# Creating directories
mkdir -p /root/
mkdir -p /var/log/parakhronos_logs/

# Logging
exec 2> /var/log/parakhronos_logs/stderr.log 1> >(tee -i /var/log/parakhronos_logs/stdout.log)

# -----------------------------------------------------------------------------
# Checking which server type is running, cPanel or VDS. Once determined this
# will download the appropriate pkg or restore script. If downloading the pkg
# script, it will also ask if you want to have it migrate to a destination
# server once packaged.
# -----------------------------------------------------------------------------
if [[ ! -f /usr/local/cpanel/cpanel ]]; then
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg.sh -O /root/pkhro_pkg.sh
  chmod 755 /root/pkhro_pkg.sh
          while :; do
            echo "Would you like this script to auto-copy the packaged account file to the destination server? [Y]es/[n]o"
            read shouldrsync
            echo
            if [ "$shouldrsync" = "Y" ] || [ "$shouldrsync" = "Yes" ] || [ "$shouldrsync" = "y" ] || [ "$shouldrsync" = "yes" ]; then
              echo "Type the full hostname of the destination/cPanel server, followed by [ENTER]:";
              read fulldesthost
              echo

              echo "Type the full path of the SSH key you wish to use, followed by [ENTER]:"
              read fullkeythost
              shouldrsync="10"
              echo
              break
            elif [ "$shouldrsync" = "N" ] || [ "$shouldrsync" = "No" ] || [ "$shouldrsync" = "n" ] || [ "$shouldrsync" = "No" ]; then
              echo "No problemo, no rsyncing at the end."; echo;
              shouldrsync="11"
              break
            else
              echo -e "\e[33m\e[1m Unrecognizable Response, Please enter [Y]es or [N]o. \e[0m";echo;echo;
            fi
          done
          echo "$shouldrsync"
elif [[ -f /usr/local/cpanel/cpanel ]]; then
  wget -q --no-check-certificate --no-cache --no-cookie https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore.sh -O /root/pkhro_restore.sh
  chmod 755 /root/pkhro_restore.sh
else
  echo "Cant Decide if this is a Package or Restore. STOP!"
  echo $(dye)
fi


# -----------------------------------------------------------------------------
# Again checking which server this is (probably could store that as a variable)
# in the previous check). Then, this makes some directories, copies the script
# and runs it. If VDS was chosen, this is the part that scp's to the
# destination server. The cPanel version generates a unique password for each
# account, restores then displays it after it restores the accounts.
# Then this cleans up everything except the original pkg file.
# -----------------------------------------------------------------------------

if [[ ! -f /usr/local/cpanel/cpanel ]] ; then
  for i in "${masteruserlist[@]}"
  do
    echo -e "\e[33m\e[1m Making $i root directory... \e[0m";sleep 1; echo
    eval mkdir -p "~$i/root/migration_scripts"
    echo -e "\e[33m\e[1m Copying script to $i root directory... \e[0m";sleep 1; echo
    eval cp -av /root/pkhro_pkg.sh "~$i/root/migration_scripts/"
    echo -e "\e[33m\e[1m Chowning root directory to $i ownership... \e[0m";sleep 1; echo
    eval chown $i: -R "~$i/root/migration_scripts/"
    echo -e "\e[33m\e[1m Running pkhro_pkg.sh inside of $i VDS... \e[0m";sleep 1; echo
    su - $i -c 'cd /root/migration_scripts/; /bin/bash pkhro_pkg.sh'
        if [ "$shouldrsync" -eq "10" ]; then
        echo -e "\e[33m\e[1m Rsyncing $i to vmcp14... \e[0m";sleep 1; echo
        eval scp -v -P 1022 -i "$fullkeythost" ~$i/root/parakhronos_restore_$i.tar root@"$fulldesthost":/root/
            if [[ $? -eq 0 ]]; then
              echo -e "\e[33m\e[1m Rsyncing $i to vmcp14 was success! \e[0m";
            else
            echo -e "\e[1m\e[41m Rsync Failure!! \e[0m";echo
            fi
        fi
    su - $i -c 'rm -rf /root/migration_scripts;'
    eval rm -f /root/pkhro_pkg.sh
  done
elif [[ -f /usr/local/cpanel/cpanel ]]; then
  for i in "${masteruserlist[@]}"
  do
    cpname=$(echo $i | cut -c -8)
    echo $cpname "$rand0pass" >> /var/log/mig_user_pass
    echo -e "\e[33m\e[1m Restoring account $i \e[0m";sleep 1; echo
    eval cd /root/
    eval ./pkhro_restore.sh $i $cpname "$rand0pass"
    sleep 5;
    echo;
  done
  echo -e "\e[33m\e[1m COPY THESE PASSWORDS NOW!!! THEY EXIST NOWHERE ELSE. \e[0m";
  echo -e "\e[33m\e[1m IF YOU DONT SAVE THESE NOW, YOU WILL HAVE TO REGENERATE FOR ALL CUSTOMERS MIGRATED \e[0m";
  echo -e "\e[33m\e[1m These corresponding password is used with anything that has a password in cPanel. \e[0m";sleep 1; echo
  cat /var/log/mig_user_pass
  echo
  rm -f /var/log/mig_user_pass
  rm -f /root/pkhro_restore.sh
else
  echo "WHAT IS THIS SERVER?!"
fi

rm -f /root/pkhro_*

exit 0
