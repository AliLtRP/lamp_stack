#!/usr/bin/bash

php_conf="LoadModule php_module modules/libphp.so
AddHandler php-script php
Include conf/extra/php_module.conf"

myadmin_conf="Alias /phpmyadmin '/usr/share/webapps/phpMyAdmin'
<Directory '/usr/share/webapps/phpMyAdmin'>
DirectoryIndex index.php
AllowOverride All
Options FollowSymlinks
Require all granted
</Directory>"

sudo pacman -Syu
sudo pacman -Si apache

#config apache
sudo sed -i '132c #LoadModule unique_id_module modules/mod_unique_id.so' /etc/httpd/conf/httpd.conf

sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd

#mysql
sudo pacman -S mysql

sudo mysql_secure_installation

sudo systemctl enable mysqld
sudo systemctl start mysqld
sudo systemctl status mysqld

#installing php , php-apache

sudo pacman -S php php-apache

#configure php
#
sudo sed -i '66c #LoadModule mpm_event_module modules/mod_mpm_event.so' /etc/httpd/conf/httpd.conf
sudo sed -i '67c LoadModule mpm_prefork_module modules/mod_mpm_prefork.so' /etc/httpd/conf/httpd.conf

if grep -q "$php_conf" /etc/httpd/conf/httpd.conf;
then
	echo "found" 
else
	echo "$php_conf" >> a.txt
fi

sudo systemctl restart httpd


#install phpmyadmin
sudo pacman -S phpmyadmin

#phpmyadmin config
sudo sed -i '917c extension=bz2' /etc/php/php.ini
sudo sed -i '931c extension=mysqli' /etc/php/php.ini
sudo sed -i '935c extension=pdo_mysql' /etc/php/php.ini

sudo chmod +w /etc/httpd/conf/extra/phpmyadmin.conf

if  grep -q "$myadmin_conf" /etc/httpd/conf/extra/phpmyadmin.conf;
then
	echo "found" 
else
	echo "$myadmin_conf" | sudo tee -a /etc/httpd/conf/extra/phpmyadmin.conf > /dev/null
fi


if grep -q "Include conf/extra/phpmyadmin.conf" /etc/httpd/conf/httpd.conf;
then
	echo "found"
else
	echo "Include conf/extra/phpmyadmin.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null
fi

sudo systemctl restart httpd

echo "lamp stack installed successfully"






