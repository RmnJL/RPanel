<!-- RPanel - مدیریت حرفه‌ای SSH و سرور با پنل تحت وب -->

<p align="center">
  <img width="160" height="160" alt="RPanel" src="xlogo.png">
</p>

<h1 align="center">RPanel</h1>
<h4 align="center">پنل مدیریت SSH و سرور - نسخه Docker و سنتی</h4>

---

## فهرست مطالب
- [معرفی](#معرفی)
- [ویژگی‌ها](#ویژگی‌ها)
- [پیش‌نیازها](#پیش‌نیازها)
- [نصب سریع (سنتی)](#نصب-سنتی)
- [نصب با Docker (پیشنهادی)](#نصب-با-docker)
- [فعال‌سازی SSL](#فعال‌سازی-ssl)
- [دستورات کاربردی](#دستورات-کاربردی)
- [پشتیبانی و ارتباط](#پشتیبانی-و-ارتباط)

---

## معرفی
RPanel یک پنل تحت وب برای مدیریت حرفه‌ای کاربران SSH، مانیتورینگ، محدودیت ترافیک، چندکاربره، ربات تلگرام و امکانات پیشرفته سرور است. این پروژه بر پایه Laravel و Nginx توسعه یافته و به راحتی روی سرور یا Docker قابل اجراست.

---

## ویژگی‌ها
- مدیریت کامل کاربران SSH و Dropbear
- محدودیت ترافیک و تاریخ انقضا برای هر کاربر
- مشاهده کاربران آنلاین و گزارش‌گیری
- پشتیبانی از چندکاربره (multiuser)
- ربات تلگرام و API
- نصب و راه‌اندازی خودکار (auto-restore .env و app)
- بهینه‌سازی کامل برای اجرا در Docker
- بدون لینک خارجی و کاملاً مستقل
- پشتیبانی از پروتکل‌های: SSH, SSH-TLS, Dropbear, WebSocket, VMess, VLess, Hysteria2, Tuic, Shadowsocks و ...
- قابلیت فعال‌سازی SSL و فیک‌سرور
- ابزارهای CLI و اسکریپت‌های مدیریتی

---

## پیش‌نیازها
- Ubuntu 20.04 یا بالاتر (برای نصب سنتی)
- Docker و Docker Compose (برای نصب پیشنهادی)

---

## نصب سنتی (روش کلاسیک)

```bash
wget -O install.sh https://raw.githubusercontent.com/RmnJL/RPanel/main/install.sh && bash install.sh
```
یا:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/RmnJL/RPanel/main/install.sh)
```

پس از نصب، اطلاعات ورود و لینک پنل به شما نمایش داده می‌شود.

---

## نصب با Docker (پیشنهادی و سریع)

1. کلون سورس:
```bash
git clone https://github.com/RmnJL/RPanel.git
cd RPanel
```
2. تنظیم فایل env:
```bash
cp .env.example Web\ Panel/app/.env # یا فایل env مناسب خود را قرار دهید
```
3. اجرای Docker Compose:
```bash
docker compose up --build
```
یا اگر docker-compose کلاسیک دارید:
```bash
docker-compose up --build
```

- پس از اجرا، سرویس‌های nginx, php-fpm و mariadb به صورت خودکار بالا می‌آیند.
- برای مشاهده پنل: آدرس `http://localhost:8080/cp/login` یا با توجه به پورت و دامنه خود مراجعه کنید.
- برای تنظیمات بیشتر، فایل‌های `docker-compose.yml` و `Dockerfile` را ویرایش کنید.

---

## فعال‌سازی SSL

برای فعال‌سازی SSL روی پنل:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/RmnJL/RPanel/main/ssl.sh)
```
- قبل از فعال‌سازی، دامنه را به IP سرور متصل کنید.
- مراحل نصب را طبق راهنما پیش بروید.

---

## دستورات کاربردی و مدیریت
- تغییر نام کاربری و رمز ادمین:
  ```bash
  bash xpanel.sh
  # یا
  xpanel
  ```
- مشاهده وضعیت سرویس‌ها و لاگ‌ها:
  ```bash
  docker compose logs
  # یا
  docker-compose logs
  ```
- حذف کامل پنل:
  ```bash
  bash xpanel.sh > گزینه حذف
  ```

---

## پشتیبانی و ارتباط
- کانال تلگرام: [@Xpanelssh](https://t.me/Xpanelssh)
- گیت‌هاب: [RPanel on GitHub](https://github.com/RmnJL/RPanel)

---

## لایسنس
این پروژه متن‌باز است و تحت لایسنس MIT منتشر شده است.

---

<p align="center">
  <b>RPanel - مدیریت آسان و حرفه‌ای سرور SSH</b>
</p>


