#!/bin/bash
# پاک‌سازی لاگ و temp هر روز
find /var/www/html/app/storage/logs/ -type f -name '*.log' -mtime +14 -delete
find /var/www/html/app/storage/framework/cache/ -type f -mtime +7 -delete
find /tmp -type f -mtime +3 -delete
