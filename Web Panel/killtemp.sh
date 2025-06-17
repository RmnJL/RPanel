#!/bin/bash
# پاک‌سازی temp و cache هر روز
find /var/www/html/app/storage/framework/cache/ -type f -mtime +7 -delete
find /tmp -type f -mtime +3 -delete
