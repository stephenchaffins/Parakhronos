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
  * [:handshake: Contributing](#handshake-contributing)
  * [:star: Show your support](#show-your-support)
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

I have re-written the main master scripts and compressed them into one script. Now you no longer have to run 4 scripts. You now run 1 script, and this script will do all the work.

This Parakhronos.sh script can be ran on the VDS Master for packaging the account. The same script can also run on the cPanel server.
<br /><br /><br />

## Usage

This is very basic. 1 script does all the work.


1. Login to the VDS Master server (not as a client), download this file:
```
    wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/parakhronos.sh; chmod 755 parakhronos.sh
```
2. To Package the account run the following command. It will take 1 or more usernames:
```
    ./parakhronos.sh user1 user2 user3
```
3. Rsync or scp the /root/parakhronos_restore_USERNAME.tar file, to the cPanel destination server.

4. Login to the cPanel server, and repeat steps 1 and 2.
```
    wget --no-check-certificate https://raw.githubusercontent.com/stephenchaffins/Parakhronos/master/parakhronos.sh; chmod 755 parakhronos.sh
    ./parakhronos.sh user1 user2 user3
```

Logs for everything this script has done is at /var/log/parakhronos.log
<br /><br /><br />


***
## :handshake: Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/stephenchaffins/Parakhronos/issues).

## :star: Show your support

Give a ⭐️ if this project helped you!

## :pencil:	 License

Copyright © 2020 [Stephen Chaffins](https://github.com/stephenchaffins).<br />
This project is [MIT](https://github.com/stephenchaffins/Parakhronos/blob/master/LICENSE) licensed.
