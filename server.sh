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

## Welcome messages – sorry, they're mandatory...
# redacted

## Some script-based variables, "global vars?"
SERVER_ADDRESS="" # When I was here, this was xxx.xxx.xxx.xxx
SERVER_USERNAME="" # Try and make sure this is the same as your local username
SERVER_PASSWORD= # Don't do it.

## Provisionally determine the system type
RUNNING_ON=$_system_type # Pretty much just Mac...
RUNNING_AROUND=$OSTYPE # Supports linux, provisionally...
RUNNING_WITH=$_system_version # Crayons?
SSH_VERSION=$(ssh -V 2>&1)
SERVER_VERSION=$(ssh $SERVER_ADDRESS uname -srm 2>&1)
SHELL_VERSION=$(uname -srm 2>&1)

## The core of the script...
if [[ ${args[0]} == "--version" ]] ; then
    echo "Server Management v0.9-nomaintain-"$RUNNING_AROUND
    echo -e "$SHELL_VERSION wired to $SERVER_VERSION \nvia $SERVER_ADDRESS - $SSH_VERSION"
    exit 1;
fi
if [[ ${args[0]} == "--help" ]] ; then
    echo "Server Management v0.9-nomaintain-"$RUNNING_AROUND
    echo -e "$SHELL_VERSION wired to $SERVER_VERSION \nvia $SERVER_ADDRESS - $SSH_VERSION"
    echo -e "\n\033[1;33mSecurity warning: \033[0;30m the remote may reject your login if you are not using tcpgate.sa.gov.au"
    echo -e "\nUsage: server.sh [Long Option] [file] ...\n\nLong Options:\n --version   - Shows version information\n --help      - Shows this message"
    echo -e "\nType 'server.sh --email-help' to send for help!"
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
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo tail -f /var/log/system"
    exit 1;
fi
if [[ ${args[0]} == "--start-tailing-apachelog" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo tail -f /var/log/apache2/error.log"
    exit 1;
fi
if [[ ${args[0]} == "--start-serving-klog" ]] ; then
    ssh root@$SERVER_ADDRESS -t "sudo cat /var/log/system"
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
if [[ ${args[0]} == "--upgrade-server" ]] ; then
    ssh $SERVER_USERNAME@$SERVER_ADDRESS -t "sudo apt-get -y upgrade"
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
    MY_PROMPT='server.sh --'
    while :
    do
      echo -n "$MY_PROMPT"
      read line
      eval "./bash.sh --$line"
      done

    exit 0
fi


# Catch no commands...
echo "Server Management v0.9-nomaintain-"$RUNNING_AROUND
echo -e "\033[1;32mAre you lost? \033[0;30mRun this command again with the --help switch for help!" 
