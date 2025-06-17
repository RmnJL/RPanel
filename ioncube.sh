#!/bin/bash
# RPanel
# بهینه‌سازی نصب ionCube Loader
set -e
ARCH=$(uname -i)
PHPV_FULL=$(php -r 'echo PHP_VERSION;')
PHPV_SHORT=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
LOADER_PATH="/usr/local/ioncube/ioncube_loader_lin_${PHPV_SHORT}.so"

# دانلود و استخراج بر اساس معماری
if [[ $ARCH == x86_64 ]]; then
  URL="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
  FILE="ioncube_loaders_lin_x86-64.tar.gz"
elif [[ $ARCH == aarch64 ]]; then
  URL="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz"
  FILE="ioncube_loaders_lin_aarch64.tar.gz"
else
  echo "Unsupported architecture: $ARCH"; exit 1
fi

wget -4 "$URL" -O "$FILE" || { echo "Download failed!"; exit 1; }
sudo tar xzf "$FILE" -C /usr/local || { echo "Extract failed!"; exit 1; }
sudo rm -f "$FILE"

# بررسی وجود فایل loader
if [ ! -f "$LOADER_PATH" ]; then
  echo "Loader not found: $LOADER_PATH"; exit 1
fi

# اضافه کردن به conf.d
CONF_FPM="/etc/php/${PHPV_SHORT}/fpm/conf.d/00-ioncube.ini"
CONF_CLI="/etc/php/${PHPV_SHORT}/cli/conf.d/00-ioncube.ini"
echo "zend_extension = $LOADER_PATH" | sudo tee "$CONF_FPM" > /dev/null
echo "zend_extension = $LOADER_PATH" | sudo tee "$CONF_CLI" > /dev/null

# اضافه کردن به php.ini اگر وجود ندارد
PHP_INI_PATH="/etc/php/${PHPV_SHORT}/fpm/php.ini"
if ! grep -q "ioncube_loader_lin" "$PHP_INI_PATH"; then
  echo "zend_extension = $LOADER_PATH" | sudo tee -a "$PHP_INI_PATH" > /dev/null
fi

# ریستارت php-fpm
sudo systemctl restart "php${PHPV_SHORT}-fpm"
# ریستارت nginx اگر نصب بود
if systemctl list-unit-files | grep -q nginx; then
  sudo systemctl restart nginx
fi
