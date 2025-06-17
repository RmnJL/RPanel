#!/bin/bash
# RPanel
clear
# مقدار پیش‌فرض udpport
udpport_default=7300
echo -e "\nPlease input UDPGW Port ."
printf "Default Port is \e[33m${udpport_default}\e[0m, let it blank to use this Port: "
read udpport
if [[ -z "$udpport" ]]; then
  udpport=$udpport_default
fi

sed -i "s/PORT_UDPGW=.*/PORT_UDPGW=$udpport/g" /var/www/html/app/.env
apt update -y
apt install -y git cmake
# حذف دایرکتوری badvpn قبلی در صورت وجود
rm -rf /root/badvpn

git clone https://github.com/ambrop72/badvpn.git /root/badvpn
mkdir /root/badvpn/badvpn-build
cd  /root/badvpn/badvpn-build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make
if [ ! -f udpgw/badvpn-udpgw ]; then
  echo "[خطا] ساخت badvpn-udpgw ناموفق بود."; exit 1
fi
cp udpgw/badvpn-udpgw /usr/local/bin
# پاک‌سازی سورس پس از نصب
cd ~
rm -rf /root/badvpn

cat >  /etc/systemd/system/videocall.service << ENDOFFILE
[Unit]
Description=UDP forwarding for RPanel badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:$udpport --max-clients 999
User=videocall

[Install]
WantedBy=multi-user.target
ENDOFFILE
# فقط اگر کاربر وجود ندارد ایجاد شود
id -u videocall &>/dev/null || useradd -r -m -s /usr/sbin/nologin videocall
systemctl enable videocall
systemctl restart videocall

