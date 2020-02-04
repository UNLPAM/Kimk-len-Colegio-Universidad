#!/bin/bash

############################################################################################
# Description: kimkelen installation from our repository that contains some modifications  #
# Usage: sudo ./install-custom.sh $(whoami)                                                #
# Author: ivan@mansillahub.ar                                                              #
############################################################################################

DIR_CONFIG=/opt/lampp/htdocs/kimkelen-application/config
USER=$1

wget http://downloads.sourceforge.net/project/xampp/BETAS/xampp-linux-1.7.7.tar.gz
tar -xzvf xampp-linux-1.7.7.tar.gz -C /opt
cd /opt/lampp/htdocs/
git clone https://github.com/UNLPam/kimkelen-application.git

cp -paf $DIR_CONFIG/propel.ini-default $DIR_CONFIG/propel.ini
cp -paf $DIR_CONFIG/databases.yml-default $DIR_CONFIG/databases.yml

sed -i 's/= mysql:dbname=#db_name#;host=#db_host#/= mysql:dbname=kimkelen;host=localhost/g' $DIR_CONFIG/propel.ini
sed -i 's/mysql:dbname=#db_name#;host=#db_host#/mysql:dbname=kimkelen;host=localhost/g' $DIR_CONFIG/databases.yml
sed -i 's/= #db_user#/= root/g' $DIR_CONFIG/propel.ini
sed -i 's/#db_user#/root/g' $DIR_CONFIG/databases.yml
sed -i 's/= #db_pass#/= /g' $DIR_CONFIG/propel.ini
sed -i 's/#db_pass#//g' $DIR_CONFIG/databases.yml

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /opt/lampp/etc/php.ini

chown -R $USER:$USER /opt/lampp/htdocs/kimkelen-application

sudo /opt/lampp/lampp start

/opt/lampp/bin/mysql -uroot -e "create database kimkelen;"
/opt/lampp/bin/mysql -uroot kimkelen < /opt/lampp/htdocs/kimkelen-application/patch/unlpam/finaldump.sql

cd /opt/lampp/htdocs/kimkelen-application/
/opt/lampp/bin/php symfony kimkelen:flavor demo
/opt/lampp/bin/php symfony project:permissions
/opt/lampp/bin/php symfony plugin:publish-assets
/opt/lampp/bin/php symfony cache:clear

git checkout -- cache/.gitkeep

echo "Instalación de Kimkëlen Finalizada :)"
echo "Visite en su navegador: localhost/kimkelen-application/web"

