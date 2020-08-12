#!/bin/bash

# -----------------------------------------------------------------------------
# @Author: Stephen Chaffins
# @Date:   2017-03-10T21:44:31-05:00
# @Email:  schaffins@techassets.com
# @Project: Parakhronos
# @Filename: pkhron_restore.sh
# @Last modified by:   schaffins
# @Last modified time: 2020-08-12T16:57:07-04:00
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Using this line to set some basic vairables.
# -----------------------------------------------------------------------------
vdsUSER=$1
cpUSER=$2
pWORD=$3
WORKDIR=/root/"$vdsUSER"_restore
PWSTRNG=$(whmapi1 get_password_strength password="$3" |grep "strength:"| awk '{gsub(" strength: ", "");print}')
#exec > >(tee -i /var/log/parakhronos_logs/main.log)
#exec 2>&1


trap "exit 1" TERM
export TOP_PID=$$

function dye()
{
   echo -e "\e[1m\e[41m Try Again! \e[0m"
   kill -s TERM $TOP_PID
}
# -----------------------------------------------------------------------------
# Check for required arguments before starting
# -----------------------------------------------------------------------------
if [ -z "$vdsUSER" ]; then
  echo
  echo -e "\e[1m\e[41m You didn't enter a VDS username!! \e[0m" ; echo
  echo $(dye)
fi

if [ -z "$cpUSER" ]; then
  echo
  echo -e "\e[1m\e[41m You didn't enter a cPanel username!! \e[0m" ; echo
  echo $(dye)
  exit
fi

if [ -z "$pWORD" ]; then
  echo
  echo -e "\e[1m\e[41m You didn't enter a default password!! \e[0m" ;echo
  echo $(dye)
  exit 1
fi

if [ "$PWSTRNG" -le "64" ]; then
  echo
  echo -e "\e[1m\e[41m You must enter a password with a strenght of 65 or more. \e[0m"; echo
  echo $(dye)
  exit 1
fi

echo
echo -e "\e[33m\e[1m Checking for Date::Parse. Installation can take some time. \e[0m";

if (perldoc -l Date::Parse | grep -q "Date/Parse.pm")
 then
   echo
   echo -e "\e[1m\e[32m Date::Parse is already installed! \e[0m" ;
else
  cpan -i Date::Parse
fi

# -----------------------------------------------------------------------------
# Creating the restore directory used.
# -----------------------------------------------------------------------------
mkdir -p /root/"$vdsUSER"_restore;

echo
# -----------------------------------------------------------------------------
# Extract the tar to the directory we just made.
# -----------------------------------------------------------------------------

if [ ! -f /root/parakhronos_restore_"$vdsUSER".tar ]; then
  echo -e "\e[1m\e[41m Restore file parakhronos_restore_$vdsUSER.tar file is not located at /root/parakhronos_restore_$vdsUSER.tar!!! \e[0m";sleep 1;echo
  echo $(dye)
else
  echo -e "\e[33m\e[1m Extracting parakhronos_restore_$cpUSER.tar now... \e[0m \e[0m \e[30;48;5;226m This can SERIOUSLY take a long time. \e[0m"
  while :; do
    printf "."
    sleep 5
  done &
  bgid=$!
  tar -xf /root/parakhronos_restore_"$vdsUSER".tar -C /root/"$vdsUSER"_restore/
  kill "$bgid"; echo
fi

echo
extractverify=$(find /root/"$vdsUSER"_restore/ ! -name . -print |grep -c /)

if [ "$extractverify" -ge 3 ]; then
  echo -e "\e[32m Compressed Archive extraction is complete...\e[0m"; echo
else
  echo -e "\e[41m\e[1m Something in the compressed archive extraction is failed! Check it manually! \e[0m"; echo
fi

# -----------------------------------------------------------------------------
# Create cPanel account.
# -----------------------------------------------------------------------------
mainDOM=$(awk '{print $1}' "$WORKDIR"/text_files/"$vdsUSER"_main_domain |sed 's/www\.//g')

echo -e "\e[32m Creating cPanel account for domain $mainDOM as user $cpUSER \e[0m";sleep 1;echo

while :; do
  printf "."
  sleep 5
done &
bgid=$!

whmapi1 --output=jsonpretty createacct username=$cpUSER domain=$mainDOM plan=Expanded password="$pWORD"

kill "$bgid"; echo

# -----------------------------------------------------------------------------
# Check that this user has been pre-created on the server.
# -----------------------------------------------------------------------------
grep "$cpUSER" /etc/passwd &>/dev/null
if [ $? -eq 1 ]
then
  echo  -e "\e[1m\e[41m Account $cpUSER not created previous step! Catastrophic failure! \e[0m"
  echo $(dye)
else
  echo  -e "\e[32m Account $cpUSER successfully created! \e[0m"
  echo
fi

# -----------------------------------------------------------------------------
# Creating addon domains and rsyncing the data to their directories
# -----------------------------------------------------------------------------

echo -e "\e[33m\e[1m Creating the addon domains and copying the data to the addon domain directory... \e[0m";
while read -r adline
do
  addom=$(echo "$adline" | awk '{print $1}')
  #addir=`echo "$adline" | awk '{print $2}'`
  subd=$(echo "$adline" | awk '{print $1}'|sed 's/.\{4\}$//')

  echo -e "\e[33m Working on addon domain $addom now... \e[0m";


  while :; do
    printf "."
    sleep 5
  done &
  bgid=$!

  cpapi2 --user="$cpUSER" --output=jsonpretty AddonDomain addaddondomain dir=%2Fhome%2F"$cpUSER"%2Fpublic_html%2F"$addom" newdomain="$addom" subdomain="$subd"

  addverify=$(grep DNS /var/cpanel/users/"$cpUSER" |grep -v XDNS| sed 's/.*=//'|grep -c ^"$addom"$)

  if [ "$addverify" -eq 1 ]; then
    echo
    echo -e "\e[32m Addon domain $addom created. \e[0m";
  else
    echo
    echo -e "\e[1m\e[41m Addon domain $addom failed! Try creating it manually. \e[0m";
  fi

if [ -z "$addom"];
then
  sleep 1;
else
  rsync -a "$WORKDIR"/domain_files/"$addom"/ /home/"$cpUSER"/public_html/"$addom"/
fi

  kill "$bgid"; echo

  adataverify=$(find /home/"$cpUSER"/public_html/"$addom" ! -name . -print |grep -c /)

  if [ "$adataverify" -ge 2 ]; then
    echo -e "\e[32m Addon domain data synced for $addom to /home/$cpUSER/public_html/$addom. \e[0m";
    echo
  else
    echo -e "\e[1m\e[41m Addon domain data sync failed for $addom! Try creating it manually. \e[0m";
    echo
  fi
done < "$WORKDIR"/text_files/"$vdsUSER"_addon_subdomains;

sleep 1;

# -----------------------------------------------------------------------------
# Create parked domains here
# -----------------------------------------------------------------------------
echo -e "\e[33m\e[1m Creating the parked domains...  \e[0m";
while read -r pdline
do
  parkdom=$(echo "$pdline" | awk '{print $1}')
  #pdom2=`echo "$pdline" | awk '{print $1}'|sed 's/.\{4\}$//'`
  cpapi2 --user="$cpUSER" --output=jsonpretty Park park domain="$parkdom"

  pdverify=$(grep DNS /var/cpanel/users/"$cpUSER" |grep -v XDNS| sed 's/.*=//'|grep -c ^"$parkdom"$)

  if [ "$pdverify" -eq 1 ]; then
    echo -e "\e[32m Parked domain $parkdom created. \e[0m";
  else
    echo -e "\e[1m\e[41m Parked domain $parkdom failed! Try parking it manually. \e[0m";
  fi

done < "$WORKDIR"/text_files/"$vdsUSER"_parked_domains;
echo

# -----------------------------------------------------------------------------
# Create subdomains domains here
# -----------------------------------------------------------------------------
echo -e "\e[33m\e[1m Creating the subdomains and copying the data...  \e[0m";


while read -r sdline
do
  mforsub=$(echo "$sdline" | awk '{print $1}' |cut -d "." -f 2,3)
  subdom1=$(echo "$sdline" |awk '{print $1}'| awk -F  "." '{print $1}')
  #subddir=`echo "$sdline" | awk '{print $2}'`
  subactual=$(echo "$sdline"| awk '{print $1}')

  echo -e "\e[33m Creating sub domain $subactual now... \e[0m";



  cpapi2 --user="$cpUSER" --output=jsonpretty SubDomain addsubdomain domain="$subdom1" rootdomain="$mforsub" dir=%2Fhome%2F"$cpUSER"%2Fpublic_html%2F"$subactual"

  sdverify=$(grep DNS /var/cpanel/users/"$cpUSER"|grep -v XDNS| sed 's/.*=//'|grep -c ^"$subactual"$)

  if [ "$sdverify" -eq 1 ]; then
    echo -e "\e[32m Subdomain $subactual created on $mforsub. \e[0m"
  else
    echo
    echo -e "\e[1m\e[41m Subdomain $subactual failed! Try creating it manually. \e[0m"
  fi;

  while :; do
    printf "."
    sleep 5
  done &
  bgid=$!

  rsync -vaP "$WORKDIR"/domain_files/"$subactual"/ /home/"$cpUSER"/public_html/"$subactual"/
  echo
  kill "$bgid"; echo

  sdataverify=$(find . ! -name . -prune -print /home/"$cpUSER"/public_html/"$subactual" |grep -c /)

  if [ "$sdataverify" -ge 2 ]; then
    echo -e "\e[32m Subdomain data synced to /home/$cpUSER/public_html/$subactual. \e[0m"; echo
  else
    echo -e "\e[1m\e[41m Subdomain domain data sync failed for $subactual! Try syncing it manually. \e[0m"; echo
  fi
done < "$WORKDIR"/text_files/"$vdsUSER"_subdomain_list;

# -----------------------------------------------------------------------------
# Copying main domain data files to public_html
# -----------------------------------------------------------------------------
echo -e "\e[33m\e[1m Copying the Main Domain data files...  \e[0m";

while :; do
  printf "."
  sleep 5
done &
bgid=$!

rsync -vaP "$WORKDIR"/domain_files/"$mainDOM"/ /home/"$cpUSER"/public_html/
chown -R "$cpUSER":"$cpUSER" /home/"$cpUSER"/public_html/*

kill "$bgid";
echo

mdomdataverify=$(diff -sq "$WORKDIR"/domain_files/"$mainDOM"/ /home/"$cpUSER"/public_html/ |awk '{print $NF}' |grep -c '^identical$')

if [ "$mdomdataverify" -ge 1 ]; then
  echo -e "\e[32m $mainDOM data synced to /home/$cpUSER/public_html/. \e[0m"; echo
else
  echo -e "\e[1m\e[41m $mainDOM data sync failed to sync to /home/$cpUSER/public_html/! Try syncing it manually. \e[0m"; echo
fi


# -----------------------------------------------------------------------------
# Creating the email addresses
# -----------------------------------------------------------------------------

echo -e "\e[33m\e[1m Creating Email Addresses for all domains... \e[0m";
while read -r mailline
do
  eusr=$(echo "$mailline" | sed 's/@.*//')
  edom=$(echo "$mailline" | sed 's/.*@//')
  uapi --user="$cpUSER" --output=jsonpretty Email add_pop email="$eusr" password="$pWORD" domain="$edom" skip_update_db=1

  if [ -d /home/"$cpUSER"/mail/"$edom"/"$eusr" ]; then
    echo -e "\e[32m Created address $eusr@$edom with default password. \e[0m";
  else
    echo -e "\e[1m\e[41m Creation of address $eusr@$edom failed! Try creating it manually! \e[0m"
  fi
done < "$WORKDIR"/text_files/"$vdsUSER"_mailusers;
echo


# -----------------------------------------------------------------------------
# Use this area to convert mailboxes.
# -----------------------------------------------------------------------------
echo -e "\e[33m\e[1m Converting Mailboxes from VDS to cPanel compatible... \e[0m";

wget -O "$WORKDIR"/mb2md.gz http://batleth.sapienti-sat.org/projects/mb2md/mb2md-3.20.pl.gz
gunzip "$WORKDIR"/mb2md.gz
chmod go+x "$WORKDIR"/mb2md

while read -r mailboxes1
do
  mailusr=$(echo "$mailboxes1" | sed 's/@.*//')
  maildom=$(echo "$mailboxes1" | sed 's/.*@//')
  #uapi --user="$cpUSER" --output=jsonpretty Email add_pop email="$eusr" password="$pWORD" domain="$edom" skip_update_db=1
  perl "$WORKDIR"/mb2md -s "$WORKDIR"/mailboxes/"$mailusr" -d /home/"$cpUSER"/mail/"$maildom"/"$mailusr"

  mbrstcheck=$(ls /home/"$cpUSER"/mail/"$maildom"/"$mailusr"/cur/ |wc -l)

  if [ "$mbrstcheck" -lt 1 ]; then
    echo -e "\e[1m\e[91m Mailbox empty, or possible failed. Manual double checking may be required. \e[0m";
  else
    echo -e "\e[32m Mailbox for "$mailusr"@"$maildom" conversion complete. \e[0m";
  fi;

done < "$WORKDIR"/text_files/"$vdsUSER"_mailusers;
echo

# -----------------------------------------------------------------------------
# Creating the databases
# -----------------------------------------------------------------------------
echo -e "\e[33m\e[1m Creating databases, database users, granting privileges, then restoring the database dumps...  \e[0m";
while read -r dblist
do
  cpUSERtrunc=$(echo "$cpUSER" | cut -c 1-8)
  dbUSERtrunc=$(echo "$dblist"| cut -c 1-7)
  dbNAME=$(echo "$cpUSERtrunc"_"$dblist")
  dbUSER=$(echo "$cpUSERtrunc"_"$dbUSERtrunc")

  echo -e "\e[33m Creating database $dbNAME now... \e[0m";
  uapi --user="$cpUSER" --output=jsonpretty Mysql create_database name="$dbNAME"
  echo -e "\e[32m Database $dbNAME creation complete. \e[0m"; echo

  echo -e "\e[33m Creating database user $dbUSER now... \e[0m";
  uapi --user="$cpUSER" --output=jsonpretty Mysql create_user name="$dbUSER" password="$pWORD"
  echo -e "\e[32m Database User $dbUSER creation complete. \e[0m"; echo

  echo -e "\e[33m Adding $dbUSER to $dbNAME with ALL PRIVILEGES now... \e[0m";
  uapi --user="$cpUSER" --output=jsonpretty Mysql set_privileges_on_database user="$dbUSER" database="$dbNAME" privileges=ALL%20PRIVILEGES  ;
  echo -e "\e[32m ALL PRIVILEGES granted to user $dbUSER on database $dbNAME \e[0m";echo

  echo -e "\e[33m Restoring database $dbNAME from $dblist.sql \e[0m";
  mysql "$dbNAME" < "$WORKDIR"/database_dumps/"$dblist".sql

  tibles=$(mysql -e 'SELECT COUNT(DISTINCT `table_name`) FROM `information_schema`.`columns` WHERE `table_schema` = "$dbNAME"'|sed -n '2 p')

  if [ "$tibles" -ge 1 ]; then
    echo -e "\e[32m Database $dbNAME restoration complete. \e[0m"; echo
  else
    echo -e "\e[1m\e[41m Database $dbNAME restoration Failed! Try restoring it manually! \e[0m"
  fi


done < "$WORKDIR"/text_files/"$vdsUSER"_databases;

# -----------------------------------------------------------------------------
# Remove the extracted contents.
# -----------------------------------------------------------------------------

rm -rf "$WORKDIR"

# -----------------------------------------------------------------------------
# Singaling the end.
# -----------------------------------------------------------------------------

echo -e "\e[1m\e[44m Restoration of $cpUSER account is complete. \e[0m";sleep 1;
echo

echo -e "\e[1m\e[41m Exiting. Done. \e[0m";echo
exit 0;
