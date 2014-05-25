#!/bin/bash
args=("$@")
## (c) 2009, 2010, 2011, 2012, 2013, 2014 Department for Education and Child Development.
## The author revokes all copyrights and responsibilities for the Government of South Australia.
## The author requests you view: https://creativecommons.org/publicdomain/zero/1.0/ 
##
## Produced by Aidan Cornelius-Bell for DECD starting 20th May 2014.
##
## Teaching for Effective Learning Virtual Server Tools - v0.9-nomaintain
## Think of this as a really bad version of something like Juju.
##
## This script is entirely designed for UNIX BSD, SunOS / MacOS. 
## Expecting compatability with Linux is probably not a great idea, 
## something might break. Good luck and have fun.
##

## Some script-based variables, "global vars?"
SERVER_ADDRESS="" # When I was here, this was 
SERVER_USERNAME="" # Try and make sure this is the same as your local username
SERVER_PASSWORD= # Don't do it.
PREFER_ROOT=false # also, probably don't do it. Will replace the username, with 'root'
PROVISION_SAFEGUARD=true

## Provisionally determine the system type
RUNNING_ON=$_system_type # Pretty much just Mac...
RUNNING_AROUND=$OSTYPE # Supports linux, provisionally...
RUNNING_WITH=$_system_version # Crayons?
SSH_VERSION=$(ssh -V 2>&1)
SHELL_VERSION=$(uname -srm 2>&1)

## Pre-function setters
if [[ $PREFER_ROOT == "true" ]] ; then
    SERVER_USERNAME="root"
fi
## Functions, and whatnot
function SET_SERVER_VERSION {
    SERVER_VERSION=$(ssh $SERVER_ADDRESS uname -srm 2>&1)
}
function STATE_GOVERNMENT_MESSAGES {
    echo -e ""
}
function SEND_HELP_EMAIL {
    # Made as a func, so I can disable it in public builds
    echo -e "\033[0;31mYou need to pipe this to telnet, type ./server.sh --email-help <my.email.server> \"<my message>\" |telnet\033[0;30m. If you're doing that, good work!"
    sleep 2
    echo "open ${args[1]} 25"
    sleep 4
    echo "MAIL FROM: "
    sleep 1
    echo "RCPT TO: "
    sleep 1
    echo "DATA"
    sleep 2
    echo "SUBJECT: [Help] Server Script Issues"
    sleep 1
    echo "Hi Aidan,"
    sleep 1
    echo "${args[2]}"
    sleep 1
    echo "."
}

## The core of the script...
if [[ ${args[0]} == "--version" ]] ; then
    STATE_GOVERNMENT_MESSAGES
    SET_SERVER_VERSION
    echo "TfEL Server Management v0.9-nomaintain-"$RUNNING_AROUND
    echo -e "$SHELL_VERSION wired to $SERVER_VERSION \nvia $SERVER_ADDRESS - $SSH_VERSION"
    exit 1;
fi
if [[ ${args[0]} == "--help" ]] ; then
    STATE_GOVERNMENT_MESSAGES
    SET_SERVER_VERSION
    echo "TfEL Server Management v0.9-nomaintain-"$RUNNING_AROUND
    echo -e "$SHELL_VERSION wired to $SERVER_VERSION \nvia $SERVER_ADDRESS - $SSH_VERSION"
    echo -e "\n\033[1;33mSecurity warning: \033[0;30mthe remote may reject your login if you are not using tcpgate.sa.gov.au"
    echo -e "\nUsage: server.sh [Long Option] [file] ...\n\nLong Options:\n --version   - Shows version information\n --help      - Shows this message"
    echo -e "\nType 'server.sh --email-help' to send for help!"
    exit 1;
fi
if [[ ${args[0]} == "--email-help" ]] ; then
    SEND_HELP_EMAIL
    exit 1;
fi
if [[ ${args[0]} == "--license" ]] ; then
    exit 1;
fi
if [[ ${args[0]} == "--clear" ]] ; then
    clear
    exit 1;
fi
if [[ ${args[0]} == "--type" ]] ; then
    echo "Interactive script :: server.sh"
    exit 1;
fi
if [[ ${args[0]} == "--variable-test" ]] ; then
    ( set -o posix ; set ) | less
    exit 1;
fi
if [[ ${args[0]} == "--fortune" ]] ; then
    echo "Beware of Bigfoot!"
    exit 1;
fi
if [[ ${args[0]} == "--test" ]] ; then    
    echo -en "Your OpenSSH client is $SSH_VERSION.\nTesting your tunnel                                    \033[1;32m"
    ssh $SERVER_USERNAME@$SERVER_ADDRESS echo "[Success]"
    echo -en "\033[0m"
	exit 1;
fi
if [[ ${args[0]} == "--whoami" ]] ; then
    #exec something
    ONE=$(whoami)
    TWO=$(hostname)
    THREE=$(ssh $SERVER_ADDRESS hostname)
    echo "Locally you are:" $ONE@$TWO
    echo "Remotely you are:" $SERVER_USERNAME@$THREE
    exit 1;
fi
if [[ ${args[0]} == "--provision-new-server" ]] ; then
    if [[ $PROVISION_SAFEGUARD == true ]] ; then
        echo -e "Uh, uh, uh! *finger waggle*"
        exit 1;
    fi
    
    if [[ $PROVISION_SAFEGUARD == false ]] ; then
    echo -e "\033[0;31mSERIOUS REPERCUSSIONS BY CONTINUING:\033[0;30m do not run this without editing this script and specifying the server!!!"
    echo -en "\033[0;31mYou will break the existing server if you continue\033[0;30m don't do it if you don't know what you're doing.\nAre you really sure you want to continue? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        echo -e "\033[0;31mYou will break everything if you continue on an existing server.\033[0;30m This is your last chance, push control+c to cancel within 10 seconds."
        sleep 11
        clear
        cat ~/.ssh/id_rsa.pub | ssh $SERVER_USERNAME@$SERVER_ADDRESS cat >> ~/.ssh/authorized_keys
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "uname -a"
        echo "Is this the correct server?"
        echo -e "[1/5] \033[4;32mProvision stage one -- clearing existing configurations & reconfiguring\033[0;30m"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo dpkg-reconfigure -phigh -a && sudo nano /etc/hostname && sudo /etc/init.d/hostname start && sudo dpkg-reconfigure tzdata"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/apt/sources.list"
        sleep 5
        echo -e "[=] Stage one complete, waiting for server to be ready to continue...\n"
        sleep 1
        echo -e "[2/5] \033[4;32mProvision stage two -- update cores and sources, then dist-upgrade\033[0;30m"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get upgrade"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get dist-upgrade"
        echo -e "[=] Stage two complete, waiting for server to be ready to continue...\n"
        sleep 1
        echo -e "[3/5] \033[4;32mProvision stage three -- install most extra packages\033[0;30m"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get install build-essential checkinstall git-core subversion tasksel software-properties-common unattended-upgrades bwm-ng htop pastebinit whois"
        echo -e "[=] Stage two complete, waiting for server to be ready to continue...\n"
        sleep 1
        echo -e "[4/5] \033[4;32mProvision stage four -- install & configure Apache, MySQL, PostgreSQL, PHP5, and some other servers\033[0;30m"
        echo -e "[+] This stage requires your input. Please enter your configurations when prompted."
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get install lamp-server\^ php-apc phpmyadmin php5-gd" # "sudo apt-get install lamp-server^"
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo tasksel postgresql-server"
        echo -e "[+] Configuring some apache2 mods and settings, you may also configure apache & php."
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo a2enmod rewrite"
        echo -en "[+] Would you like to edit the default configurations? [Recommended] (y/n) "
        read yesno
        if [[ "$yesno" == "y" ]] ; then
            echo " ---> *** Reconfiguring & Nanoing into unattended-upgrades"
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo dpkg-reconfigure unattended-upgrades && sudo nano /etc/apt/apt.conf.d/50unattended-upgrades"
            echo " ---> *** Nanoing into PHP5..."
            echo -en "Reccomended config:\nshort_open_tag = On\nmax_execution_time = 30\nmemory_limit = 128M\nerror_reporting = E_ALL & \~E_DEPRECATED\ndisplay_errors = Off\nlog_errors = On\npost_max_size = 8M\nupload_max_filesize = 8M\ndate.timezone = Australia/South\n"
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/php5/apache2/php.ini"
            echo " ---> *** Nanoing into Apache2..."
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/apache2/apache2.conf"
            echo " ---> *** Nanoing into PHP5 APC..."
            echo -en "Reccomended config:\nextension = apc.so \napc.shm_size = 128\n"
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/php5/conf.d/apc.ini"
            echo " ---> *** Nanoing into sshd_config..."
            echo -en "Reccomended config:\nPermitRootLogin no\n"
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/ssh/sshd_config && sudo /etc/init.d/sshd restart"
        fi
        echo -en "[+] Is this server for production, or development? [Production reccomended] (prod/dev)"
        read yesno
        if [[ "$yesno" == "dev" ]] ; then
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo addgroup webdev && sudo chgrp -R webdev /var/www/ && sudo chmod -R g+rw /var/www/ && sudo find /var/www -type d -exec chmod +s {} \\; && sudo usermod -a -G webdev www-data && sudo usermod -a -G webdev root"
        fi
        if [[ "$yesno" == "prod" ]] ; then
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo addgroup webprod && sudo chgrp -R webprod /var/www/ && sudo chmod -R g+rw /var/www/ && sudo find /var/www -type d -exec chmod +s {} \\; && sudo usermod -a -G webprod www-data && sudo usermod -a -G webprod root"
        fi
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo service apache2 restart"
        sleep 2
        echo -e "[=] Stage two complete, waiting for server to be ready to continue...\n"
        sleep 1
        echo -e "[5/5] \033[4;32mProvision stage five -- update boot records, confirm successful configurations, reboot server for first login\033[0;30m"
        echo -e "[=] Provisioning has finished. Use this script with the --enable-password-free-login option to grant this computer passwordless login.\n\n"
        exit 1;
    fi
    fi
    exit 1;
fi
if [[ ${args[0]} == "--start-x-session" ]] ; then
    echo "Oops, start this inside XQuartz"
    exit 1;
fi
if [[ ${args[0]} == "--start-ssh-session" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS
    echo "Goodbye!"
    exit 1;
fi
if [[ ${args[0]} == "--start-ssh-root-session" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo -i"
    exit 1;
fi
if [[ ${args[0]} == "--start-tailing-klog" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo tail -f /var/log/syslog"
    exit 1;
fi
if [[ ${args[0]} == "--start-tailing-apachelog" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo tail -f /var/log/apache2/error.log"
    exit 1;
fi
if [[ ${args[0]} == "--start-serving-klog" ]] ; then
    ssh root@$SERVER_ADDRESS -t "sudo cat /var/log/syslog"
    exit 1;
fi
if [[ ${args[0]} == "--start-serving-apachelog" ]] ; then
    ssh root@$SERVER_ADDRESS -t "sudo cat /var/log/apache2/error.log"
    exit 1;
fi
if [[ ${args[0]} == "--ps:mysql" ]] ; then
    ssh root@$SERVER_ADDRESS "ps aux | grep mysql | grep -v grep"
    exit 1;
fi
if [[ ${args[0]} == "--ps:apache" ]] ; then
    ssh root@$SERVER_ADDRESS "ps aux | grep apache | grep -v grep"
    exit 1;
fi
if [[ ${args[0]} == "--ps:aux" ]] ; then
    ssh root@$SERVER_ADDRESS "ps aux"
    exit 1;
fi
if [[ ${args[0]} == "--update-server" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get update"
    exit 1;
fi
if [[ ${args[0]} == "--service-restart" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo service ${args[1]} restart"
    exit 1;
fi
if [[ ${args[0]} == "--service-stop" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo service ${args[1]} stop"
    exit 1;
fi
if [[ ${args[0]} == "--service-start" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo service ${args[1]} start"
    exit 1;
fi
if [[ ${args[0]} == "--upgrade-server" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get -y upgrade"
    exit 1;
fi
if [[ ${args[0]} == "--add-user" ]] ; then
    NEW_USER_NAME=${args[1]}
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo useradd -g www-data --shell=/bin/false $NEW_USER_NAME && mkdir -p /home/$NEW_USER_NAME/web-$NEW_USER_NAME/www/ && mkdir -p /home/$NEW_USER_NAME/web-$NEW_USER_NAME/cgi-bin/ && sudo chgrp -R webprod /home/$NEW_USER_NAME/ && sudo chmod -R g+rw /home/$NEW_USER_NAME/"
    echo "Done!"
    exit 1;
fi
if [[ ${args[0]} == "--remove-user" ]] ; then
    NEW_USER_NAME=${args[1]}
    echo -e "\033[0;31mRemeber:\033[0;30m before deleting a user, delete their site!"
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo usermod -L $NEW_USER_NAME"
    echo -en "\033[4;34mUser locked out of their profile. \033[0;30m\nYou can also choose to erase their login and all data, do that now? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "userdel $NEW_USER_NAME && sudo rm -r /home/$NEW_USER_NAME/"
    fi
    exit 1;
    echo "Done!"
fi
if [[ ${args[0]} == "--add-apache-site" ]] ; then
    NEW_SITE_NAME=${args[1]}
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo cp /etc/apache2/sites-available/new-template.conf /etc/apache2/sites-available/new-$NEW_SITE_NAME.conf"
    echo -en "\033[4;34mCreated new virtual-site configuration.\033[0;30m\nYou will need to edit it before it works, would you like to do that now? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo nano /etc/apache2/sites-available/new-$NEW_SITE_NAME.conf"
        echo -en "\033[0;31mI'm now going to enable that site, then reload apache\033[0;30m – this may cause a major disruption if you didn't configure the vhost correctly, continue? (y/n) "
        read yesno
        if [[ "$yesno" == "y" ]] ; then
            ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo a2ensite new-$NEW_SITE_NAME; sudo service apache2 reload; exit"
        fi
    fi
    echo "Done!"
    exit 1;
fi
if [[ ${args[0]} == "--remove-apache-site" ]] ; then
    NEW_SITE_NAME=${args[1]}
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo a2dissite new-$NEW_SITE_NAME && sudo rm /etc/apache2/sites-available/new-$NEW_SITE_NAME.conf && sudo rm /etc/apache2/sites-enabled/new-$NEW_SITE_NAME.conf"
    echo -en "\033[0;31mI'm going to disable that site, then reload apache\033[0;30m continue? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo a2dissite new-$NEW_SITE_NAME; sudo service apache2 reload; exit"
    fi
    echo "Done!"
    exit 1;
fi
if [[ ${args[0]} == "--distrubution-upgrade-server" ]] ; then
    echo -en "\n\033[1;33mServices may be interrupted:\033[0;30m Are you sure? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get -y dist-upgrade"
    fi
    exit 1;
fi
if [[ ${args[0]} == "--uptime-server" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS uptime
    exit 1;
fi
if [[ ${args[0]} == "--restart-server" ]] ; then
    echo -en "\n\033[1;33mServices will be interrupted:\033[0;30m Are you sure? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo reboot"
    fi
    exit 1;
fi
if [[ ${args[0]} == "--enable-password-free-login" ]] ; then
    cat ~/.ssh/id_rsa.pub | ssh $SERVER_USERNAME@$SERVER_ADDRESS cat >> ~/.ssh/authorized_keys
    exit 1;
fi
if [[ ${args[0]} == "--enable-password-free-root-login" ]] ; then
        echo -en "\n\033[1;33mPotential security hole:\033[0;30m Are you sure? (y/n) "
    read yesno
    if [[ "$yesno" == "y" ]] ; then
        cat ~/.ssh/id_rsa.pub | ssh root@$SERVER_ADDRESS cat >> ~/.ssh/authorized_keys
    fi
    exit 1;
fi
if [[ ${args[0]} == "--interactive-mode" ]] ; then
    STATE_GOVERNMENT_MESSAGES
    MY_PROMPT='server.sh --'
    while :
    do
      echo -n "$MY_PROMPT"
      read line
      eval "./server.sh --$line"
      done

    exit 0
fi

# Catch no commands...
STATE_GOVERNMENT_MESSAGES
echo "TfEL Server Management v0.9-nomaintain-"$RUNNING_AROUND
echo -e "\033[1;32mAre you lost? \033[0;30mRun this command again with the --help switch for help!" 
