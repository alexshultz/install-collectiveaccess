# Collective Access Installation Guide (Mac)

This guide provides step-by-step instructions for installing and configuring Collective Access on a Mac system.

## Prerequisites

- macOS (Homebrew will be installed as part of this process)
- Terminal access

## Installation Steps

### 1. Install Homebrew

Open Terminal and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Required Packages

Navigate to the directory containing your Brewfile and run:

```bash
brew bundle
```

### 3. Verify PHP Installation

```bash
php -v
```

### 4. Configure MySQL

Start MySQL service:

```bash
brew services start mysql
```

Secure MySQL installation:

```bash
mysql_secure_installation
```

Follow the prompts:
- Set password to: `PXBarn1860-1861`
- Remove anonymous users
- Restrict root login to local only
- Remove the test database
- Reload the privileges table

Create database and user:

```sql
mysql -u root -p
CREATE DATABASE collectiveaccess;
CREATE USER 'collectiveaccess'@'localhost' IDENTIFIED BY 'PXBarn1860-1861';
GRANT ALL PRIVILEGES ON collectiveaccess.* TO 'collectiveaccess'@'localhost';
FLUSH PRIVILEGES;
quit
```

### 5. Configure Apache

Start Apache:

```bash
brew services start httpd
```

Edit Apache settings:

```bash
# Enable rewrite module
sed -i '' 's/^#LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/' $HOMEBREW_PREFIX/etc/httpd/httpd.conf

# Change listen port from 8080 to 80
sed -i '' 's/Listen 8080/Listen 80/g' $HOMEBREW_PREFIX/etc/httpd/httpd.conf

# Load PHP module (use appropriate path for your system)
sed -i '' '/LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/a\
LoadModule rewrite_module  \/opt\/homebrew\/lib\/httpd\/modules\/libphp.so' $HOMEBREW_PREFIX/etc/httpd/httpd.conf
```

Configure PHP in Apache:

```bash
echo '<IfModule php_module>
  <FilesMatch \.php$>
    SetHandler application/x-httpd-php
  </FilesMatch>

  <IfModule dir_module>
    DirectoryIndex index.html index.php
  </IfModule>
</IfModule>
Include /usr/local/etc/httpd/extra/httpd-php.conf' | tee -a $HOMEBREW_PREFIX/etc/httpd/httpd.conf
```

Restart Apache:

```bash
brew services restart httpd
```

### 6. Install PHP Extensions

```bash
pecl install channel://pecl.php.net/gmagick-2.0.6RC1
```

Restart Apache:

```bash
brew services restart httpd
```

Verify the installation:

```bash
php -m | grep gmagick
```

### 7. Install Collective Access

Clone the repository:

```bash
cd $HOMEBREW_PREFIX/var/www
git clone -b dev/php8 https://github.com/collectiveaccess/providence.git ca
```

Update permissions:

```bash
sudo chown -R alex:www $HOMEBREW_PREFIX/var/www/ca
sudo chmod -R 775 $HOMEBREW_PREFIX/var/www/ca
```

Update Apache configuration:

```bash
echo '<Directory "/usr/local/var/www/ca">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>' | tee -a $HOMEBREW_PREFIX/etc/httpd/httpd.conf
```

Restart Apache:

```bash
brew services restart httpd
```

### 8. Configure Providence

Copy and edit the setup file:

```bash
cp $HOMEBREW_PREFIX/var/www/ca/setup.php-dist $HOMEBREW_PREFIX/var/www/ca/setup.php
```

Edit `setup.php` with the following settings:

```php
define("__CA_DB_USER__", 'collectiveaccess');
define("__CA_DB_PASSWORD__", 'PXBarn1860-1861');
define("__CA_DB_DATABASE__", 'collectiveaccess');
define("__CA_APP_DISPLAY_NAME__", "Pony Express Barn and Museum CollectiveAccess System");
define("__CA_ADMIN_EMAIL__", 'alex.shultz@gmail.com');
date_default_timezone_set('America/Chicago');
define("__CA_USE_CLEAN_URLS__", 1);
define('__CA_ALLOW_INSTALLER_TO_OVERWRITE_EXISTING_INSTALLS__', true);
define('__CA_STACKTRACE_ON_EXCEPTION__', true);
```

Install vendor libraries:

```bash
cd $HOMEBREW_PREFIX/var/www/ca/
cp ~/Documents/Brew/PX/providence-composer.json ./composer.json
cp ~/Documents/Brew/PX/providence-composer.lock ./composer.lock
composer install --no-interaction --no-dev --optimize-autoloader
```

### 9. Configure Installation Profiles

```bash
rm $HOMEBREW_PREFIX/var/www/ca/install/profiles/xml/*.xml
cp ~/Documents/Brew/PX/px_profile.xml $HOMEBREW_PREFIX/var/www/ca/install/profiles/xml
```

Edit user setup profile:

```bash
awk '/show_bundle_codes_in_editor/ {c=1} c && /default = hide,/ {sub(/default = hide,/, "default = show,"); c=0} 1' $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.conf > $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.tmp.conf && mv $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.tmp.conf $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.conf
```

Edit app.conf:

```bash
sed -i '' 's/allow_duplicate_id_number_for_ca_objects = 1/allow_duplicate_id_number_for_ca_objects = 0/' $HOMEBREW_PREFIX/var/www/ca/app/conf/app.conf
```

Edit Count widget:

```bash
sed -i.bak '/show_ca_storage_locations/,/description => _t/{s/\('default' => \)0,/\11,/}' $HOMEBREW_PREFIX/var/www/ca/app/widgets/count/countWidget.php
```

### 10. Install Pawtucket

Clone Pawtucket repository:

```bash
cd $HOMEBREW_PREFIX/var/www/ca
git clone -b dev/php8 http://github.com/collectiveaccess/pawtucket2.git pawtucket
```

Update permissions:

```bash
sudo chown -R alex:www $HOMEBREW_PREFIX/var/www/ca/pawtucket
sudo chmod -R 755 $HOMEBREW_PREFIX/var/www/ca/pawtucket
```

Install vendor libraries:

```bash
cd $HOMEBREW_PREFIX/var/www/ca/pawtucket
composer update
```

Configure Pawtucket:

```bash
cp $HOMEBREW_PREFIX/var/www/ca/pawtucket/setup.php-dist $HOMEBREW_PREFIX/var/www/ca/pawtucket/setup.php
```

Edit `setup.php` with similar settings as Providence.

### 11. Configure Media Access

Edit Pawtucket's global.conf file:

```bash
sed -i '' 's/ca_media_url_root = <ca_url_root>\/media\/<app_name>/ca_media_url_root = \/ca\/media\/<app_name>/' "$HOMEBREW_PREFIX/var/www/ca/pawtucket/app/conf/global.conf"
sed -i '' 's/ca_media_root_dir = <ca_base_dir>\/media\/<app_name>/ca_media_url_root = \/opt\/homebrew\/var\/www\/ca\/media\/<app_name>/' "$HOMEBREW_PREFIX/var/www/ca/pawtucket/app/conf/global.conf"
```

### 12. Custom Theme

Copy the theme file:

```bash
cp ~/Documents/Brew/PX/pawtucket/themes/px $HOMEBREW_PREFIX/var/www/ca/pawtucket/themes/
```

Set the theme in Pawtucket's setup.php:

```bash
sed -i "" "s/'_default_' 	=> 'default'		\/\/ use the 'default' theme for everything else/'_default_' 	=> 'px'		\/\/ use the 'default' theme for everything else/g" $HOMEBREW_PREFIX/var/www/ca/pawtucket/setup.php
```

## Additional Notes

- For updating Providence git files, refer to the git commands provided in the original document.
- JWT key configuration and GraphQL client setup instructions are available in the original document.
- Install wkhtmltopdf manually from [https://wkhtmltopdf.org/downloads.html](https://wkhtmltopdf.org/downloads.html)

## Troubleshooting

If you encounter any issues during the installation process, please refer to the error messages and consult the Collective Access documentation or community forums for support.

## Contributing

If you find any errors in this guide or have suggestions for improvements, please feel free to contribute by submitting a pull request or opening an issue in the project repository.

## License

This project is licensed under the [Creative Commons Zero v1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) (CC0 1.0) Public Domain Dedication.

You can:

- Copy, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.

For more information, see the [LICENSE](./LICENSE) file.
