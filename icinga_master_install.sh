#!/bin/bash
#This script has been written by Alexander 'Sleggerthorn' Kramer
#This script is an installation script, following the guidelines found on https://icinga.com/docs/icinga-2/latest/doc/02-installation/
#I do not take responsibility for regular updates. This project could be abandoned anytime. In fact, right now, it doesn´t has my main focus
boolean_os = 0
echo "Welcome dear User, this script installs the icinga master on your current device"
echo "Please notice that, due to compability, this script only works for linux based operating systems"
echo "if you´re using a Windows, please contact the icinga documentation for further help"
echo "!!!!!!!!!!!!!!!!!"
wait 30s
while [ boolean_os == 0 ]
do
    echo "Let´s get started by choosing your operation system"
    echo "Please choose from the following:"
    echo "1: Ubuntu"
    echo "2: Debian"
    echo "3: Windows"
    echo "Please enter your Number by choosing the numbers from 1 to 3: "
    read choosen_os
    wait 1s
    echo "Is ".choosen_os." the right operating system?"
    echo "Press 1 for true and 0 for false: "
    read boolean_os
if [ choosen_os == "1"]
then
    apt-get update
    apt-get -y install apt-transport-https wget gnupg

    wget -O - https://packages.icinga.com/icinga.key | apt-key add -. /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
    echo "deb https://packages.icinga.com/ubuntu icinga-${DIST} main" > \ /etc/apt/sources.list.d/${DIST}-icinga.list
    echo "deb-src https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \ /etc/apt/sources.list.d/${DIST}-icinga.list
    apt-get update
fi

if [ choosen_os == "2"]
then
    apt-get update
    apt-get -y install apt-transport-https wget gnupg

    wget -O - https://packages.icinga.com/icinga.key | apt-key add -DIST=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release); \
    echo "deb https://packages.icinga.com/debian icinga-${DIST} main" > \/etc/apt/sources.list.d/${DIST}-icinga.list
    echo "deb-src https://packages.icinga.com/debian icinga-${DIST} main" >> \ /etc/apt/sources.list.d/${DIST}-icinga.list

    apt-get update
fi
apt-get install icinga2 && apt-get install monitoring-plugins

echo "Do you want to install Icinga Web 2? Please Press 1 for yes and 0 for false: "
read boolean_icinga_web
if [boolean_icinga_web == 1]
then
    echo "Please make a administrative account for your mysql server with the name 'icinga'"
    wait 2s
    apt-get install mariadb-server mariadb-client
    mysql_secure_installation
    wait 2s
    apt-get install icinga2-ido-mysql
    wait 2s
    mysql -u root -p icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
    icinga2 feature enable ido-mysql
    systemctl restart icinga2
    wait 1s
    apt-get install apache2
    firewall-cmd --add-service=http
    firewall-cmd --permanent --add-service=http
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
    service iptables save
    wait 1s
    icinga2 api setup
fi
echo "Please finish the following configurations manually. You have to switch to the configurations and edit the icinga web 2 administration profile found under /etc/icinga2/conf.d/api-users.conf"
echo "Please edit the password and username to an secure user and password."
apt-get install nano -y
nano /etc/icinga2/conf.d/api-users.conf
systemctl restart icinga2