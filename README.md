[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GNU License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">

  <h3 align="center">Parakhronos</h3>

  <p align="center">
    VDS to cPanel Migration Script
    <br />
    <a href="https://github.com/stephenchaffins/Parakhronos"><strong>Explore the docs »</strong></a>
    <br />
    <a href="https://github.com/stephenchaffins/Parakhronos/issues">Report Bug</a>
    ·
    <a href="https://github.com/stephenchaffins/Parakhronos/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [Packaging Script](#packaging-script)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

Parakhronos is a migration application written to automate migrations between the legacy product "Sphera VDS Control Panel" to the new and ever updated cPanel control panel.

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


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=flat-square
[contributors-url]: https://github.com/stephenchaffins/Parakhronos/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=flat-square
[forks-url]: https://github.com/stephenchaffins/Parakhronos/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=flat-square
[stars-url]: https://github.com/stephenchaffins/Parakhronos/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=flat-square
[issues-url]: https://github.com/stephenchaffins/Parakhronos/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=flat-square
[license-url]: https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/stephen-chaffins-39412760/
