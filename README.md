# SSH Port & Tunnel Manager

[English](#english) · [فارسی](#persian)

<a id="english"></a>

## English

A small interactive Bash utility for managing OpenSSH service state, adding a second SSH listening port, and creating or removing local Linux accounts intended for SSH tunnelling.

> [!CAUTION]
> **Review the security behavior before installing this on an internet-facing server.** The current installer enables SSH password authentication globally, enables TCP forwarding and TUN/TAP tunnelling globally, and sets PermitOpen any. The menu also writes newly created users' passwords in plain text to /etc/ssh/ssh-users.txt. This can expose accounts and expand access to your server. Use only on a server you control, and harden the script and SSH policy before production use.
>
> The installer changes the SSH daemon configuration, disables SSH socket activation, and restarts SSH. Keep an existing SSH session open and have provider console access available: a configuration or firewall issue could interrupt remote access. The initial SSH configuration is not automatically backed up before these changes.

### Quick install

On a Debian/Ubuntu-style system with apt and systemd, run:

~~~bash
curl -fsSL https://raw.githubusercontent.com/alirezahdr/ssh-port-tunnel-manager/main/install.sh | sudo bash
~~~

Then open the interactive menu:

~~~bash
sudo ssh-menu
~~~

The command downloads and executes the installer as root. Review [install.sh](install.sh) before running it, especially on a remote or production server.

### Requirements

- A Linux server using apt and systemd (the script is written for Debian/Ubuntu-style systems).
- Root access, either directly or through sudo.
- An active network connection to download packages.
- SSH server configuration at /etc/ssh/sshd_config and a systemd service named ssh.

The installer runs apt update, installs ssh, sed, grep, and nano, and places the menu at /usr/local/bin/ssh-menu.

### Menu options

| Option | Action |
| --- | --- |
| 1 | Start the SSH service |
| 2 | Stop the SSH service |
| 3 | Show SSH service status and listening sockets |
| 4 | Add a second SSH port (the script keeps port 22 in its configuration) |
| 5 | Show configured and live SSH ports |
| 6 | Create a Linux account intended for tunnelling |
| 7 | Delete a Linux account |
| 8 | List accounts recorded by the menu |
| 9 | Continuously monitor SSH listening sockets |
| B | Back up the current sshd_config |
| R | Restore a selected backup |
| 0 | Exit |

Backups created through the menu are stored in /etc/ssh/backup. The menu enables the ssh service at boot when it starts.

### What the installer changes

- Disables and removes two systemd links for ssh.socket, then reloads systemd.
- Edits /etc/ssh/sshd_config to enable password authentication, TCP forwarding, TUN/TAP tunnelling, unrestricted PermitOpen, and port 22.
- Restarts the SSH service.
- Installs the interactive ssh-menu command.

There is no automated uninstall command in the current repository. The menu's backup and restore options operate on sshd_config; they do not undo every systemd or account change made by the installer.

### Files used

- /usr/local/bin/ssh-menu — installed interactive menu.
- /etc/ssh/sshd_config — SSH daemon configuration modified by the installer and menu.
- /etc/ssh/backup/ — configuration backups created using the menu.
- /etc/ssh/ssh-users.txt — account records written by the menu, currently including passwords in plain text.

### Reporting issues

Open a GitHub issue with your Linux distribution and version, the command or menu option used, and the relevant error output. Do not post passwords, private keys, IP allowlists, or other credentials.

---

<a id="persian"></a>

## فارسی

یک ابزار کوچک و تعاملی با Bash برای مدیریت سرویس OpenSSH، افزودن پورت دوم SSH و ساخت یا حذف حساب‌های لینوکسی مورد استفاده برای تونل SSH.

> [!CAUTION]
> **پیش از نصب روی سروری که از اینترنت در دسترس است، رفتار امنیتی اسکریپت را بررسی کنید.** نصب‌کننده احراز هویت SSH با رمز را برای کل سرور فعال می‌کند، فوروارد TCP و تونل TUN/TAP را به‌صورت سراسری فعال می‌کند و مقدار PermitOpen any را تنظیم می‌کند. همچنین منو رمز حساب‌های ساخته‌شده را به‌صورت متن ساده در /etc/ssh/ssh-users.txt می‌نویسد. این کار ممکن است اطلاعات حساب‌ها را افشا کند و سطح دسترسی سرور را گسترش دهد. فقط روی سروری که کنترلش را دارید استفاده کنید و پیش از استفادهٔ عملیاتی، اسکریپت و سیاست SSH را ایمن‌سازی کنید.
>
> نصب‌کننده تنظیمات SSH را تغییر می‌دهد، فعال‌سازی سوکتی SSH را غیرفعال می‌کند و سرویس SSH را راه‌اندازی مجدد می‌کند. یک نشست SSH فعلی را باز نگه دارید و دسترسی کنسول ارائه‌دهندهٔ سرور را هم داشته باشید؛ خطای تنظیمات یا فایروال ممکن است دسترسی راه دور را قطع کند. پیش از این تغییرها، از تنظیمات اولیه SSH نسخهٔ پشتیبان خودکار گرفته نمی‌شود.

### نصب سریع

روی سیستم‌های مبتنی بر Debian/Ubuntu که apt و systemd دارند، اجرا کنید:

~~~bash
curl -fsSL https://raw.githubusercontent.com/alirezahdr/ssh-port-tunnel-manager/main/install.sh | sudo bash
~~~

سپس منوی تعاملی را باز کنید:

~~~bash
sudo ssh-menu
~~~

این دستور نصب‌کننده را دانلود می‌کند و با دسترسی root اجرا می‌کند. پیش از اجرا، به‌خصوص روی سرور راه دور یا عملیاتی، فایل [install.sh](install.sh) را بخوانید.

### پیش‌نیازها

- سرور لینوکسی با apt و systemd؛ اسکریپت برای سیستم‌های مبتنی بر Debian/Ubuntu نوشته شده است.
- دسترسی root یا دسترسی از طریق sudo.
- اتصال اینترنت برای دریافت بسته‌ها.
- فایل تنظیمات SSH در /etc/ssh/sshd_config و سرویس systemd با نام ssh.

نصب‌کننده apt update را اجرا می‌کند، بسته‌های ssh، sed، grep و nano را نصب می‌کند و منو را در /usr/local/bin/ssh-menu قرار می‌دهد.

### گزینه‌های منو

| گزینه | عملکرد |
| --- | --- |
| 1 | اجرای سرویس SSH |
| 2 | متوقف کردن سرویس SSH |
| 3 | نمایش وضعیت سرویس و سوکت‌های در حال شنود |
| 4 | افزودن پورت دوم SSH؛ اسکریپت پورت 22 را در تنظیمات خود نگه می‌دارد |
| 5 | نمایش پورت‌های تنظیم‌شده و فعال SSH |
| 6 | ساخت حساب لینوکسی برای تونل |
| 7 | حذف حساب لینوکسی |
| 8 | نمایش حساب‌های ثبت‌شده در منو |
| 9 | پایش پیوستهٔ سوکت‌های SSH |
| B | تهیهٔ نسخهٔ پشتیبان از sshd_config |
| R | بازگردانی یک نسخهٔ پشتیبان انتخاب‌شده |
| 0 | خروج |

نسخه‌های پشتیبان منو در /etc/ssh/backup ذخیره می‌شوند. هنگام اجرای منو، سرویس ssh برای اجرا در زمان راه‌اندازی سیستم فعال می‌شود.

### تغییرهایی که نصب‌کننده اعمال می‌کند

- سوکت ssh.socket و دو پیوند systemd مربوط به آن را غیرفعال یا حذف می‌کند و پیکربندی systemd را دوباره بارگذاری می‌کند.
- فایل /etc/ssh/sshd_config را برای فعال‌سازی احراز هویت با رمز، فوروارد TCP، تونل TUN/TAP، مقدار آزاد PermitOpen و پورت 22 تغییر می‌دهد.
- سرویس SSH را راه‌اندازی مجدد می‌کند.
- دستور منوی تعاملی ssh-menu را نصب می‌کند.

در نسخهٔ فعلی مخزن، دستور حذف خودکار وجود ندارد. گزینه‌های پشتیبان‌گیری و بازگردانی منو فقط روی sshd_config کار می‌کنند و تمام تغییرهای systemd یا حساب‌های ساخته‌شده را برنمی‌گردانند.

### فایل‌های مورد استفاده

- /usr/local/bin/ssh-menu — منوی تعاملی نصب‌شده.
- /etc/ssh/sshd_config — فایل تنظیمات SSH که نصب‌کننده و منو تغییر می‌دهند.
- /etc/ssh/backup/ — نسخه‌های پشتیبان تهیه‌شده از طریق منو.
- /etc/ssh/ssh-users.txt — فهرست حساب‌های ثبت‌شده؛ در نسخهٔ فعلی رمزها نیز به‌صورت متن ساده در آن نوشته می‌شوند.

### گزارش مشکل

برای گزارش مشکل، نسخه و توزیع لینوکس، دستور یا گزینهٔ منو و متن خطای مرتبط را در یک Issue گیت‌هاب بنویسید. رمز، کلید خصوصی، فهرست IPهای مجاز یا اطلاعات محرمانه را منتشر نکنید.
