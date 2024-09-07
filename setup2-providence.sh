#!/bin/zsh

# Define Homebrew Prefix
HOMEBREW_PREFIX=$(brew --prefix)

# Setup Providence PHP
cp $HOMEBREW_PREFIX/var/www/ca/setup.php-dist $HOMEBREW_PREFIX/var/www/ca/setup.php

# Edit setup.php settings
# Customize the providence setup.php file

# Original: define("__CA_DB_USER__", 'my_database_user');
sed -i "" "s/define(\"__CA_DB_USER__\", 'my_database_user');/define(\"__CA_DB_USER__\", 'collectiveaccess');/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: define("__CA_DB_PASSWORD__", 'my_database_password');
sed -i "" "s/define(\"__CA_DB_PASSWORD__\", 'my_database_password');/define(\"__CA_DB_PASSWORD__\", 'PXBarn1860-1861');/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: define("__CA_DB_DATABASE__", 'name_of_my_database');
sed -i "" "s/define(\"__CA_DB_DATABASE__\", 'name_of_my_database');/define(\"__CA_DB_DATABASE__\", 'collectiveaccess');/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: define("__CA_APP_DISPLAY_NAME__", "My First CollectiveAccess System");
sed -i "" "s/define(\"__CA_APP_DISPLAY_NAME__\", \"My First CollectiveAccess System\");/define(\"__CA_APP_DISPLAY_NAME__\", \"Pony Express Barn and Museum CollectiveAccess System\");/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: define("__CA_ADMIN_EMAIL__", 'info@put-your-domain-here.com');
sed -i "" "s/define(\"__CA_ADMIN_EMAIL__\", 'info@put-your-domain-here.com');/define(\"__CA_ADMIN_EMAIL__\", 'alex.shultz@gmail.com');/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: date_default_timezone_set('America/New_York');
sed -i "" "s|date_default_timezone_set('America/New_York');|date_default_timezone_set('America/Chicago');|" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Original: define("__CA_USE_CLEAN_URLS__", 0);
sed -i "" "s/define(\"__CA_USE_CLEAN_URLS__\", 0);/define(\"__CA_USE_CLEAN_URLS__\", 1);/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

#REMOVE for production
# Original: define('__CA_ALLOW_INSTALLER_TO_OVERWRITE_EXISTING_INSTALLS__', false);
sed -i "" "s/define('__CA_ALLOW_INSTALLER_TO_OVERWRITE_EXISTING_INSTALLS__', false);/define('__CA_ALLOW_INSTALLER_TO_OVERWRITE_EXISTING_INSTALLS__', true);/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

#REMOVE for production
# Original: define('__CA_STACKTRACE_ON_EXCEPTION__', false);
sed -i "" "s/define('__CA_STACKTRACE_ON_EXCEPTION__', false);/define('__CA_STACKTRACE_ON_EXCEPTION__', true);/g" $HOMEBREW_PREFIX/var/www/ca/setup.php

# Install vendor libraries
cd $HOMEBREW_PREFIX/var/www/ca/
cp ~/Documents/Brew/PX-Mini/providence-composer.json ./composer.json
cp ~/Documents/Brew/PX-Mini/providence-composer.lock ./composer.lock
composer install --no-interaction --no-dev --optimize-autoloader

# Copy Installation Profiles
cp ~/Documents/Brew/PX-Mini/px_profile.xml $HOMEBREW_PREFIX/var/www/ca/install/profiles/xml

# Edit user setup profile
#awk '/show_bundle_codes_in_editor/ {c=1} c && /default = hide,/ {sub(/default = hide,/, "default = show,"); c=0} 1' $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.conf > $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.tmp.conf && mv $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.tmp.conf $HOMEBREW_PREFIX/var/www/ca/app/conf/user_pref_defs.conf

# Edit app.conf
#sed -i '' 's/allow_duplicate_id_number_for_ca_objects = 1/allow_duplicate_id_number_for_ca_objects = 0/' $HOMEBREW_PREFIX/var/www/ca/app/conf/app.conf

# Install local conf files
cd $HOMEBREW_PREFIX/var/www/ca/
cp ~/Documents/Brew/PX-Mini/conf/local/* ./app/conf/local/

