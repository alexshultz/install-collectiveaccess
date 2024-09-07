#!/bin/zsh

# Define Homebrew Prefix
HOMEBREW_PREFIX=$(brew --prefix)

# Edit apache settings that are in this file
# Turn on rewrite
sed -i '' 's/^#LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/' "$HOMEBREW_PREFIX/etc/httpd/httpd.conf"

# Change listen port from 8080 to 80
sed -i '' 's/Listen 8080/Listen 80/g' "$HOMEBREW_PREFIX/etc/httpd/httpd.conf"

# Load the PHP module
sed -i '' '/LoadModule rewrite_module lib\/httpd\/modules\/mod_rewrite.so/a\
LoadModule php_module \/usr\/local\/lib\/httpd\/modules\/libphp.so
' "$HOMEBREW_PREFIX/etc/httpd/httpd.conf"

# Finish PHP setup
{
  echo '<IfModule php_module>'
  echo '  <FilesMatch \.php$>'
  echo '    SetHandler application/x-httpd-php'
  echo '  </FilesMatch>'
  echo ''
  echo '  <IfModule dir_module>'
  echo '    DirectoryIndex index.html index.php'
  echo '  </IfModule>'
  echo '</IfModule>'
} | tee -a "$HOMEBREW_PREFIX/etc/httpd/extra/httpd-php.conf"

echo 'Include /usr/local/etc/httpd/extra/httpd-php.conf' | tee -a "$HOMEBREW_PREFIX/etc/httpd/httpd.conf"

# Install php-gmagick extension
pecl install channel://pecl.php.net/gmagick-2.0.6RC1

# Add the extension to php.ini
echo 'extension=gmagick.so' | tee -a "$HOMEBREW_PREFIX/etc/php/8.2/php.ini"
