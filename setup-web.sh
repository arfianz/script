#!/bin/sh

# Melakukan update repositori dan update sistem
sudo apt install -y git
sudo apt install -y software-properties-common
sudo apt install -y unzip
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update && sudo apt upgrade -y

# Instalasi Apache Web Server
sudo apt install -y apache2
sudo rm -f /etc/apache2/sites-available/000-default.conf

sudo tee -a /etc/apache2/sites-available/000-default.conf << END
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        <Directory /var/www/html>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
END

sudo tee -a /var/www/html/.htaccess << END
RewriteEngine on
END

sudo systemctl restart apache2

# Instalasi PHP7
sudo apt install -y php7.1 libapache2-mod-php7.1 php7.1-common php7.1-sqlite3 php7.1-curl php7.1-intl php7.1-mbstring php7.1-mcrypt php7.1-xmlrpc php7.1-mysql php7.1-gd php7.1-xml php7.1-cli php7.1-zip

sudo sed -i "s/.*file_uploads =.*/file_uploads = On/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*allow_url_fopen =.*/allow_url_fopen = On/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*short_open_tag =.*/short_open_tag = On/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*memory_limit =.*/memory_limit = 256M/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*upload_max_filesize =.*/upload_max_filesize = 100M/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*upload_max_filesize =.*/upload_max_filesize = 100M/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*max_execution_time =.*/max_execution_time = 360/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/.*date.timezone =.*/date.timezone = Asia\/Jakarta/" /etc/php/7.1/apache2/php.ini

sudo tee -a /var/www/html/info.php << END
<?php
  phpinfo();
?>
END

sudo systemctl restart apache2

# Download file ossn
cd /tmp && wget https://www.opensource-socialnetwork.org/download_ossn/latest/build.zip

# Unzip file ossn
unzip build.zip

# Memindahkan file hasil unzip ke document root
echo -e "$Green \n Sedang instalasi OSSN.. $Color_Off"
sudo mv ossn /var/www/html/ossn

# Membuat data folder untuk ossn
sudo mkdir /var/www/html/ossn_data

# Mengubah permission ke www-data
sudo chown -R www-data:www-data /var/www/html/ossn/
sudo chmod -R 755 /var/www/html/ossn/
sudo chown -R www-data:www-data /var/www/html/ossn_data

# Membuat konfig ossn di apache
sudo tee -a /etc/apache2/sites-available/ossn.conf << END
<VirtualHost *:80>
	ServerAdmin admin@example.com
	DocumentRoot /var/www/html/ossn
	ServerName localhost
	<Directory /var/www/html/ossn/>
		Options FollowSymlinks
		AllowOverride All
		Require all granted
	</Directory>
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
END

# Restart Service Apache
sudo a2ensite ossn.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
