#!/bin/bash
# RPanel
def_port=$(grep "PORT_PANEL=" /var/www/html/app/.env | awk -F "=" '{print $2}')
read -rp "Please enter the pointed domain / sub-domain name: " domain
sudo apt update && sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d $domain || { echo "[خطا] صدور گواهی SSL ناموفق بود."; exit 1; }

sudo tee /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name $domain;
    root /var/www/html/example;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param PHP_VALUE "memory_limit=4096M";
    }
    location ~ /\.ht {
        deny all;
    }
     location /ws
    {
    proxy_pass http://127.0.0.1:8880/;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_read_timeout 52w;
    }
}
server {
    listen 8443 ssl;
    server_name $domain;

    root /var/www/html/example;
    index index.php index.html;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param PHP_VALUE "memory_limit=4096M";
    }

    location ~ /\.ht {
        deny all;
    }
    location /ws {
        if (\$http_upgrade != "websocket") {
                return 404;
        }
        proxy_pass http://127.0.0.1:8880;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 52w;
    }
}
server {
    listen ${def_port} ssl;
    server_name $domain;
    root /var/www/html/cp;
    index index.php index.html;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param PHP_VALUE "memory_limit=4096M";
    }
    location ~ /\.ht {
        deny all;
    }
}
EOF
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl reload nginx

multiin="https://${domain}:$def_port/fixer/multiuser"
cat > /var/www/html/kill.sh << ENDOFFILE
#!/bin/bash
#By RPanel
for ((i=0;i<10;i++)); do
  curl -s -H "A: B" "$multiin" &
  sleep 6
done
ENDOFFILE
chmod +x /var/www/html/kill.sh

othercron="https://${domain}:$def_port/fixer/other"
cat > /var/www/html/other.sh << ENDOFFILE
#!/bin/bash
#By RPanel
for ((i=0;i<3;i++)); do
  curl -s -H "A: B" "$othercron" &
  sleep 17
done
ENDOFFILE
chmod +x /var/www/html/other.sh

# حذف selective کرون‌جاب‌های پنل
crontab -l 2>/dev/null | grep -vE '/var/www/html/(kill|other|killlog|dropbear|killtemp)\.sh|/fixer/|/send/email' | crontab -

# افزودن کرون‌جاب‌های جدید بدون تکرار
add_cron() {
  local job="$1"
  (crontab -l 2>/dev/null | grep -v -F -- "$job"; echo "$job") | crontab -
}
add_cron "* * * * * /var/www/html/kill.sh"
add_cron "* * * * * /var/www/html/other.sh"
add_cron "0 */1 * * * /var/www/html/killlog.sh"
add_cron "0 3 * * * /var/www/html/killtemp.sh"
add_cron "* * * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/exp' > /dev/null 2>&1"
add_cron "0 * * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/checkhurly' > /dev/null 2>&1"
add_cron "*/10 * * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/checktraffic' > /dev/null 2>&1"
add_cron "*/15 * * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/checkfilter' > /dev/null 2>&1"
add_cron "0 0 * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/send/email/3day' > /dev/null 2>&1"
add_cron "0 0 * * * wget -q -O /dev/null 'https://${domain}:$def_port/fixer/send/email/24h' > /dev/null 2>&1"
if dpkg -l | grep -q dropbear; then
  add_cron "* * * * * /var/www/html/dropbear.sh"
fi
clear
printf "\nHTTPS Address : https://${domain}:$def_port/login \n"
