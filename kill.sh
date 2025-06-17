#!/bin/bash
#By RPanel
# بررسی وضعیت multiuser از پنل قبل از اجرای kill
PANEL_URL="$1"
if [ -z "$PANEL_URL" ]; then
  echo "[خطا] لطفاً آدرس پنل را به عنوان پارامتر وارد کنید. مثال: $0 http://domain:port"
  exit 1
fi
# بررسی وضعیت multiuser
multiuser_status=$(curl -s "$PANEL_URL/api/settings/multiuser")
if [ "$multiuser_status" != "active" ]; then
  exit 0
fi
for ((i=0;i<10;i++)); do
  curl -s -H "A: B" "$PANEL_URL/fixer/multiuser" &
  sleep 6
done
