#!/bin/bash

# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins <schaffins>
# @Date:   2020-08-12T04:46:47-04:00
# @Email:  schaffins@jumpline.com
# @Project: Parakhronos
# @Filename: parakhronos.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-12T13:26:06-04:00
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Setting some basic variables just to get us started. This includes the list
# of users that will be used. A single user name can be used. This is ran with
# something like /parakhronos.sh USERNAME USERNAME2.
# -----------------------------------------------------------------------------

IFS=$'\n'
masteruserlist=( "$@" )

# -----------------------------------------------------------------------------
# Find out what kind of server it is. VDS master, VDS client, or cpanel.
# -----------------------------------------------------------------------------

if [[ ! -f /usr/local/cpanel/cpanel ]] || [[ -d /sphera ]] ; then
  echo "This is VDS Master Server"
elif [[ ! -f /usr/local/cpanel/cpanel ]] || [[ ! -d /sphera ]]; then
  echo "This is a VDS User Account"
elif [[ -f /usr/local/cpanel/cpanel ]]; then
  echo "This is a cPanel Server"
  echo $masteruserlist
else
  echo "WHAT IS THIS SERVER?!"
fi

exit 0
