# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins <schaffins>
# @Date:   2020-08-12T04:41:20-04:00
# @Email:  schaffins@jumpline.com
# @Project: Parakhronos
# @Filename: pkhro_pkg_master.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-12T09:29:13-04:00
# -----------------------------------------------------------------------------

#!/bin/bash

exec 2>> /var/log/parakhronos_master.log

# -----------------------------------------------------------------------------
# get a list of VDS accounts on the server, maybe other variables
# -----------------------------------------------------------------------------

IFS=$'\n'
#vdsusrlist=($(cat /etc/passwd|grep sphera|grep -vE 'sd.*admn'|awk -F':' '{print $1}'))
vdsusrlist=( "$@" )

# -----------------------------------------------------------------------------
# Check if the /root directory exists, create if not
# -----------------------------------------------------------------------------

if [ ! -d /root ]
then
  mkdir /root
fi

# -----------------------------------------------------------------------------
# download the script to be used
# -----------------------------------------------------------------------------

wget -q --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg.sh -O /root/pkhro_pkg.sh

# -----------------------------------------------------------------------------
# The stuff. Everything here is ran  inside the vds/as the user. Making the
# /root directory, copying the script to that root directory, chowning and
# chmoding the dir and script, and then finally running the script as the user
# -----------------------------------------------------------------------------

for i in "${vdsusrlist[@]}"
do
  echo -e "\e[33m\e[1m Making $i root directory... \e[0m";sleep 1; echo
    eval mkdir -p "~$i/root/"
  echo -e "\e[33m\e[1m Copying script to $i root directory... \e[0m";sleep 1; echo
    eval cp -av /root/pkhro_pkg.sh "~$i/root/"
  echo -e "\e[33m\e[1m Chowning root directory to $i ownership... \e[0m";sleep 1; echo
    eval chown $i: -R "~$i/root/"
  echo -e "\e[33m\e[1m Running pkhro_pkg.sh inside of $i VDS... \e[0m";sleep 1; echo
    su - $i -c 'cd /root/; /bin/bash pkhro_pkg.sh'
    echo -e "\e[33m\e[1m Rsyncing $i to vmcp14... \e[0m";sleep 1; echo
done

exit 0
