<h1 align="center">Welcome to Parakhronos :mage: </h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.5-blue.svg?cacheSeconds=2592000" />
  <img src="https://img.shields.io/badge/bash-%3E%3D3.00.15-blue.svg" />
  <a href="https://github.com/stephenchaffins/Parakhronos#readme" target="_blank">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-yes-brightgreen.svg" />
  </a>
  <a href="https://github.com/stephenchaffins/Parakhronos/graphs/commit-activity" target="_blank">
    <img alt="Maintenance" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" />
  </a>
  <a href="https://github.com/stephenchaffins/Parakhronos/blob/master/LICENSE" target="_blank">
    <img alt="License: GNU" src="https://img.shields.io/github/license/stephenchaffins/Parakhronos" />
  </a>
</p>

> VDS to cPanel Migration Script

### :house_with_garden: [Homepage](https://github.com/stephenchaffins/Parakhronos)

<!-- TOC START min:1 max:3 link:true asterisk:true update:true -->
  * [Prerequisites](#prerequisites)
  * [Author](#author)
  * [About Parakhronos](#about-parakhronos)
  * [VDS Packaging Script](#vds-packaging-script--pkhro_pkgsh--to-be-ran-inside-the-vds-)
  * [VDS to cPanel Restoration Script](#vds-to-cpanel-restoration-script--pkhro_restoresh--to-be-ran-on-cpanel-)
  * [VDS Packaging Master Script](#vds-packaging-master-script--pkhro_pkg_mastersh--to-be-ran-on-vds-master-as-root-)
  * [VDS Restoration Master Script ](#vds-restoration-master-script--pkhro_restore_mastersh--to-be-ran-on-cpanel-server-as-root-)
  * [:handshake: Contributing](#handshake-contributing)
  * [Show your support](#show-your-support)
  * [:pencil:	 License](#pencil-license)
<!-- TOC END -->



## Prerequisites

- bash >=3.00.15

## Author

:bust_in_silhouette: **Stephen Chaffins**

* GitHub: [@stephenchaffins](https://github.com/stephenchaffins)
* LinkedIn: [@stephenchaffins](https://linkedin.com/in/stephen-chaffins-39412760)

***

## About Parakhronos

:information_source: Parakhronos is a migration application written to automate migrations between the legacy product "Sphera VDS Control Panel" to the new and ever updated cPanel control panel.

Parakhronos is:
- Written entirely in bash
- Easy to use
- Not for production use without some serious vetting first. This is script that I primarily use for my own migrations, and have to update it frequently to work with out specific settups.  Test it thouroughly.
<br /><br /><br />

## VDS Packaging Script : pkhro_pkg.sh [ To be ran inside the VDS ]

This is very basic. If you are wanting to migrate a single account, you can use this script.


1. Login to the vds, download this file.
```
    wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg.sh; chmod 755 pkhro_pkg.sh
```
2. To execute it just run:
```
    ./pkhro_pkg.sh
```
It is very important that I should mention, this is ran INSIDE of the VDS, as the VDS user.

Logs for everything this script has done is at /var/log/parakhronos.log
<br /><br /><br />

## VDS to cPanel Restoration Script : pkhro_restore.sh [ To be ran on cPanel ]

Again, this is if you're  wanting to migrate a single account. This restores the package that you just made, with the commands found above.

1. Next is the restoration script. This is more complicated to run, slightly, and requires some arguments. This script is ran on the cPanel server.

2. rsync the file (/root/parakhronos_restore_USERNAME.tar.gz) from the VDS server to the cPanel server you plan on restoring to. This has to be at /root/parakhronos_restore_USERNAME.tar.gz on the cPanel server as well.
3. Download this pkhro_restore.sh from this github repo.

        wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore.sh; chmod 755 pkhro_restore.sh

4. This must be executed with bash, not sh.

5. This requires that you input the VDS username, then the cPanel username, and the password within single quotes. It will look like this:

        ./pkhro_restore.sh VDSUSERNAME CPANELUSERNAME 'password'

This should do everything you need. You can remove the /root/parakhronos_restore_USERNAME.tar.gz file once everything looks good.

Logs for everything the script has done is at /var/log/parakhronos/CPANELUSERNAME_parakhronos.log
<br /><br /><br />

## VDS Packaging Master Script : pkhro_pkg_master.sh [ To be ran on VDS master as root ]

1. This is the master script. It's to be ran on the VDS master server as the root user. Not inside of the VDS, not as the user. This will package all of the VDS's on the server and put them in ~USER/root/ right now. Maybe it'll move everything to /root/vds_migration/ in the end. Not sure yet.

2. Download this pkhro_pkg_master.sh from this github repo.

        wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_pkg_master.sh; chmod 755 pkhro_pkg_master.sh

3. You should just be able to run this. It will look like this:

        ./pkhro_pkg_master.sh USER1 USER2 USER3 USERETC

4. This should output the packaging of each account to the screen. It'll do them in order, one by one. Log should be at /var/log/parakhronos_master.log on the VDS master.
<br /><br /><br />

## VDS Restoration Master Script : pkhro_restore_master.sh [ To be ran on cPanel server as root ]

1. This is the restoration master script. It's to be ran on the cPanel server as the root user. This is only to be ran if you're restoring multiple packages at first, and well, you need to make sure you have the proper usernames.

2. Download this pkhro_pkg_master.sh from this github repo.

        wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/pkhro_restore_master.sh; chmod 755 pkhro_restore_master.sh

3. You should just be able to run this. It will look like this:

        ./pkhro_restore_master.sh USER1 USER2 USER3 USERETC

4. This should restore all of the accounts you specified, and SHOULD output a list of passwords created, that correspond with each account. This list isnt saved anywhere, so you need to save it then delete after you update your records/billing client.

***
## :handshake: Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/stephenchaffins/Parakhronos/issues).

## Show your support

Give a ⭐️ if this project helped you!

## :pencil:	 License

Copyright © 2020 [Stephen Chaffins](https://github.com/stephenchaffins).<br />
This project is [GNU](https://github.com/stephenchaffins/Parakhronos/blob/master/LICENSE) licensed.
