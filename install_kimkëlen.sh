#!/bin/bash

#Variables
SHARED_FOLDER=$1
XAMPP=xampp-linux-1.7.7.tar.gz
KIMKELEN=v2.29.5.tar.gz

LOCAL_XAMPP=$SHARED_FOLDER/$XAMPP
LOCAL_KIMKELEN=$SHARED_FOLDER/$KIMKELEN
DOWNLOAD_XAMPP=$(pwd)/$XAMPP
DOWNLOAD_KIMKELEN=$(pwd)/$KIMKELEN

DIR_LAMPP=/opt/lampp
DIR_INSTALL_ROOT=/opt/lampp/htdocs
DIR_INSTALL_OLD=/opt/lampp/htdocs/kimkelen-2.29.5
DIR_INSTALL_NEW=/opt/lampp/htdocs/kimkelen
DIR_CONFIG=$DIR_INSTALL_NEW/config

FLAVOR=$2

decompress(){

	if [ -f "$LOCAL_XAMPP" ] && [ -f "$LOCAL_KIMKELEN" ]; then
		tar -xzvf $LOCAL_XAMPP -C /opt
	       	tar -xzvf $LOCAL_KIMKELEN -C $DIR_INSTALL_ROOT
	else
		tar -xzvf $DOWNLOAD_XAMPP -C /opt
		tar -xzvf $DOWNLOAD_KIMKELEN -C $DIR_INSTALL_ROOT
	fi
}

download(){

	wget http://downloads.sourceforge.net/project/xampp/BETAS/xampp-linux-1.7.7.tar.gz
	wget https://github.com/Desarrollo-CeSPI/kimkelen/archive/v2.29.5.tar.gz
}

install_system(){

        $DIR_LAMPP/bin/php $DIR_INSTALL_NEW/symfony kimkelen:flavor $FLAVOR
        $DIR_LAMPP/bin/php $DIR_INSTALL_NEW/symfony propel:build-all-load --no-confirmation
        $DIR_LAMPP/bin/php $DIR_INSTALL_NEW/symfony project:permissions
        $DIR_LAMPP/bin/php $DIR_INSTALL_NEW/symfony plugin:publish-assets
        $DIR_LAMPP/bin/php $DIR_INSTALL_NEW/symfony cache:clear
}

config_apache(){

	sed -i 's/ServerName localhost/ServerName kimkelen.com/g' $DIR_LAMPP/etc/httpd.conf
	sed -i "s/DocumentRoot '/opt/lampp/htdocs'/DocumentRoot '/opt/lampp/htdocs/kimkelen/web'/g" $DIR_LAMPP/etc/httpd.conf
}

install_all(){

	mv $DIR_INSTALL_OLD $DIR_INSTALL_NEW
	cp $DIR_CONFIG/propel.ini-default $DIR_CONFIG/propel.ini
	cp $DIR_CONFIG/databases.yml-default $DIR_CONFIG/databases.yml
	sed -i 's/= mysql:dbname=#db_name#;host=#db_host#/= mysql:dbname=kimkelen;host=localhost/g' $DIR_CONFIG/propel.ini
	sed -i 's/= #db_user#/= root/g' $DIR_CONFIG/propel.ini
	sed -i 's/= #db_password#/= /g' $DIR_CONFIG/propel.ini
	sed -i "s/'mysql:dbname=#db_name#;host=#db_host#'/'mysql:dbname=kimkelen;host=localhost'/g" $DIR_CONFIG/databases.yml
	sed -i 's/#db_user#/root/g' $DIR_CONFIG/databases.yml
	sed -i 's/#db_pass#//g' $DIR_CONFIG/databases.yml
	sed -i 's/memory_limit = 128M/memory_limit = 512M/g' $DIR_LAMPP/etc/php.ini

	#Lampp Start
	$DIR_LAMPP/lampp start
	$DIR_LAMPP/bin/mysql -u root -e "CREATE DATABASE kimkelen;"

	#Install Kimkelen
	install_system

	#Configure Apache
	#config_apache
}

remove_all(){
	
	$DIR_LAMPP/lampp stop
	rm -rf $DIR_LAMPP
}
 
read -n1 -p $'\e[94m¿Desea Reinstalar Kimkëlen? [Y,n]:\e[0m ' input

if [[ $input == "Y" || $input == "y" ]]; then
	echo -e "\n\nSe Eliminará la versión actualmente instalada de Kimkëlen y se instalará nuevamente. Disfrute el proceso!!"
	sleep 3
	remove_all
else
    echo -e "\n\nComenzará la Instalación Kimkëlen. Disfrute el proceso!!"    
	sleep 3
fi

if [ -d "$SHARED_FOLDER" ] && [ -f "$LOCAL_XAMPP" ] && [ -f "$LOCAL_KIMKELEN" ]; then
	decompress
	install_all
	#config_apache
else
	download
	decompress
	install_all
	#config_apache
fi

echo -e "\n¡\e[92mKimkëlen Instalado! :)"