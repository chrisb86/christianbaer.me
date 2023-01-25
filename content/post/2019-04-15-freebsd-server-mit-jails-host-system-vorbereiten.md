---
title: "FreeBSD-Server mit Jails: Host-System vorbereiten"
date: 2019-04-15T23:59:27+02:00
draft: false
type: post
tags: ["freebsd","iocage","jails"]
description: ""
### Bilder Shortcode
### {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
### {{< imgproc photo Resize "700x" />}}
---
Da bei mir mal wieder das Neuaufsetzen eines Servers ansteht, dachte ich, ich dokumentiere das ganze mal. Als Betriebssystem kommt [FreeBSD](https://freebsd.org) zum Einsatz. Das Basissystem soll möglichst schlank gehalten werden. Die einzelnen Dienste werden jeweils in eigenen Jails separiert. Beim Management der Jails kommt [iocage](https://iocage.io/) zum Einsatz.

Zuerst installieren wir die aktuellste FreeBSD-Version. Bei mir ist das aktuell Version _12.0-RELEASE_. Für die Installation habe ich das Memstick-Image benutzt. Der installer ist relativ selbst erklärend. Wichtig ist nur, dass wir für die Installation die Option _ZFS_ im Partionierungsmenü nutzen.

### System updaten

Nach der Installation booten wir in unser jungfräuliches System und updaten erst ein mal die Installation und die Ports auf das aktuellste Patchlevel.

```sh
freebsd-update fetch install
portsnap auto
```

Anschließend nehmen wir noch ein paar kleine Anpassungen vor.

#### Zeitsynchronisation aktivieren

Der Server synchronisiert beim Booten die Zeit mit deutschen Zeitservern.

```sh
sysrc ntpdate_enable="YES"
sysrc ntpdate_hosts="de.pool.ntp.org"
```

#### Bootdelay reduzieren

Die Wartezeit beim Booten wird auf drei Sekunden reduziert.

```sh
echo "autoboot_delay=3" >> /boot/loader.conf
```

#### System bleibt bei Shutwdown hängen, wenn root auf einem USB-Device liegt

Falls FreeBSD auf einem USB-Device installiert wurde, kann es sein, dass das System nach dem Shutdown hängen bleibt. Ein Reboot ist nur per Hardware-Taste möglich. Folgender Befehl fixt das.

```sh
echo "hw.usb.no_shutdown_wait=1" >> /etc/sysctl.conf
sysctl hw.usb.no_shutdown_wait=1
```

Anschließend starten wir das System noch mal neu.

### User hinzufügen

Per default ist das Login mit _root_ über _SSH_ deaktiviert. Das ist auch sinnvoll. Wir werden uns also einen User zum Arbeiten erstellen und diesen in die Lage versetzen, root-Rechte zu erlangen.

Über _adduser_ legen wir uns als erstes einen User an, mit welchem wir uns per SSH einloggen können.

```sh
adduser
```

Wir beantworten einfach die Fragen. Die angebotenen Standard-Optionen passen soweit. Hier muss nichts geändert werden. Wenn die Frage **"Invite $USER into other groups?"** kommt, geben wir zusätzlich noch die Gruppe _wheel_ an. So gehört unser User zu den Administratoren. In einem weiteren Schritt werden wir _doas_ installieren, damit wir dann auch root-Rechte erlangen können.

#### doas installieren

```sh
pkg install doas
echo "permit keepenv :wheel" > /usr/local/etc/doas.conf
```

Die Zeile **permit keepenv :wheel** sagt _doas_, dass alle Benutzer, welche der Gruppe _wheel_ angehören, durch Eingabe ihres Passworts root werden können.

Jetzt sind wir in der Lage, uns per SSH mit dem Server zu verbinden und dann auch Dinge wie Copy und Paste zu nutzen, um die Configs zu erstellen.

Mit einem behrtzten **doas -s** gelangen wir nach Eingabe unseres Passworts in eine root-Shell.

### Build-System einrichten

Ich bin ein großer Fan davon, die Programme nicht als Binärpakete zu installieren, sondern selbst aus den Ports zu bauen. So kann ich unnötige Funktionen deaktivieren und das Host-System schön schlank halten, da ich versuche, überflüssige Abhängigkeiten weitestgehend zu vermeiden.

Als erstes legen wir _/etc/make.conf_ und _/etc/src.conf_ an. In diesen Files habe ich ein paar Defaults konfiguriert, um z.B. immer die aktuelle OpenSSL-Version aus den Ports zu nehmen, X11-Funktionen zu deaktivieren, da wir ja auf einem Server sind usw.. _/etc/src.conf_ kommt zum Einsatz, falls wir uns einen angepassten Kernel bauen wollen. Da _VIMAGE_ mittlerweile im Standard-Kernel ist, besteht nicht mehr zwingend die Notwendigkeit dazu.

```sh
### /etc/make.conf

## Nearby mirror
MASTER_SITE_OVERRIDE="ftp://ftp.de.freebsd.org/pub/FreeBSD/ports/distfiles/"

## Build
MAKE_JOBS_NUMBER?=4
## Optimizations
CPUTYPE?=native
OPTIONS_SET=OPTIMIZED_CFLAGS CPUFLAGS

## Headless server options
WITHOUT_MODULES=sound ntfs linux

.if ${.CURDIR:M/usr/ports/*}
OPTIONS_SET+=CRYPTO GSSAPI_NONE IPV6 OPENSSL THREADS
OPTIONS_UNSET+=DEBUG DTRACE GSSAPI_BASE GSSAPI_HEIMDAL GSSAPI_MIT READLINE TEST TESTS X11 CUPS DOCS FONTCONFIG NLS X11 EXAMPLES
DEFAULT_VERSIONS+=ssl=openssl
.endif

## Disable sendmail!
NO_SENDMAIL=true

#ccache
WITH_CCACHE_BUILD=yes

CCACHE_UMASK=022
CCACHE_DIR=/var/cache/ccache
CCACHE_MAXSIZE=5G
```

```sh
### /etc/src.conf

WITH_CCACHE_BUILD=yes
WITHOUT_AMD=YES
WITHOUT_APM=YES
WITHOUT_ATF=YES
WITHOUT_ATM=YES
WITHOUT_AUTHPF=YES
WITHOUT_AUTOFS=YES
WITHOUT_BHYVE=YES
WITHOUT_BLUETOOTH=YES
WITHOUT_BOOTPARAMD=YES
WITHOUT_BOOTPD=YES
WITHOUT_BSNMP=YES
WITHOUT_CALENDAR=YES
WITH_CCACHE_BUILD=YES
WITHOUT_CCD=YES
WITH_CLANG_EXTRAS=YES
WITHOUT_CTM=YES
WITHOUT_CUSE=YES
WITHOUT_DEBUG_FILES=YES
WITHOUT_DMAGENT=YES
WITHOUT_FINGER=YES
WITHOUT_FLOPPY=YES
WITHOUT_GAMES=YES
WITHOUT_GPIB=YES
WITHOUT_GPIO=YES
WITH_GSSAPI=YES
WITHOUT_HTML=YES
WITHOUT_HYPERV=YES
WITHOUT_I4B=YES
WITHOUT_INETD=YES
WITHOUT_INFO=YES
WITHOUT_IPX=YES
WITHOUT_KERBEROS=YES
WITHOUT_KVM=YES
WITHOUT_LIB32=YES
WITHOUT_LPR=YES
WITHOUT_NCP=YES
WITHOUT_NDIS=YES
WITHOUT_NIS=YES
WITHOUT_PC_SYSINSTALL=YES
WITHOUT_PMC=YES
WITHOUT_PPP=YES
#WITHOUT_PROFILE=YES
WITHOUT_RADIUS_SUPPORT=YES
WITHOUT_RBOOTD=YES
WITHOUT_RCMDS=YES
WITHOUT_RCS=YES
WITHOUT_SENDMAIL=YES
WITHOUT_SHAREDOCS=YES
WITHOUT_SYSINSTALL=YES
WITHOUT_TALK=YES
WITHOUT_TCP_WRAPPERS=YES
WITHOUT_TESTS=YES
WITHOUT_TFTP=YES
WITHOUT_TIMED=YES
WITHOUT_WIRELESS=YES
```

#### ccache als Compiler-Cache

Viele Pakete, die wir bauen, werden in mehreren Jails und auf dem Host-System benötigt. Es bietet sich also an, die Kompilate zu cachen, um beim erneuten Bauen Zeit zu sparen. Hier kommt _ccache_ zum Einsatz.

Die grundlegende Konfiguration haben wir bereits in _/etc/make.conf_ und _/etc/src.conf_ getätigt. Unter anderem ist _/var/cache/ccache_ als Ort des Caches festgelegt.

Wir erstellen uns also hierfür erst mal ein ZFS-Dataset

```sh
zfs create zroot/var/cache
zfs create zroot/var/cache/ccache
```

Anschließend installieren wir _ccache_ und _portmaster_.

```sh
pkg install ccache portmaster
```

_portmaster_ macht es uns sehr viel einfacher, mit den Ports zu hantieren. Statt **cd /usr/ports/sysutils/ccache && make install clean** reicht jetzt ein **portmaster sysutils/ccache**, um _ccache_ zu installieren. Ein **portmaster -Bad** aktualisiert z.B alle installierten Ports und erstellt hierbei keine Backup-Packages. die Manpages zu _portmaster_ nennen noch viele weitere Optionen. Durch _ccache_ wird jeder Compile-Vorgang, der schon mal ausgeführt wurde, beim nächsten mal wesentlich schneller vonstatten gehen.

### Weitere nützliche Programme installieren

Wenn das alles geschafft ist, installiere ich immer noch ein paar weitere Programme, um mir die Arbeitsumgebung an meine Bedürfnisse anzupassen.

```sh
portmaster -Bd editors/vim-console net/mosh shells/zsh sysutils/tmux devel/git-lite net/rsync
```

Zu guter letzt setze ich mir dann noch _ZSH_ als Shell, installiere meine [dotfiles](https://github.com/chrisb86/dotfiles.git) und alles ist so, wie ich es auf meinen Servern gerne habe.

### Weitere sinnvolle Anpassungen

#### ssmtp

Ich finde es immer ganz praktisch, wenn mein Server mir Mails schicken kann, wenn irgend etwas nicht funktioniert. Hierfür nutze ich seit einiger Zeit _ssmtp_, ein Programm, welches Mails an einen externen Mailserver weiterreicht und von dort aus versendet.

```sh
portmaster -Bd mail/ssmtp
```

Konfiguriert wird _ssmtp_ in _/usr/local/etc/ssmtp/ssmtp.conf_.

```sh
### /usr/local/etc/ssmtp/ssmtp.conf

root=admin@example.org
mailhub=mail.example.org:587
rewriteDomain=example.com
hostname=_HOSTNAME_
FromLineOverride=YES
UseTLS=YES
UseSTARTTLS=YES
AuthUser=ssmtp@example.org
AuthPass=SuperSecret-Passw0rd!
AuthMethod=LOGIN
```

Abschließend setzen wir _ssmtp_ in der _/etc/mail/mailer.conf_ als Standard und wir sind fertig.

```sh
### /etc/mail/mailer.conf

sendmail        /usr/local/sbin/ssmtp
send-mail       /usr/local/sbin/ssmtp
mailq           /usr/local/sbin/ssmtp
newaliases      /usr/local/sbin/ssmtp
hoststat        /usr/bin/true
purgestat       /usr/bin/true
```

#### Festplatten mit smartd überwachen

Zum Auslesend des SMART-Status meiner Festplatten nutze ich _smartd_ aus den _smartmontools_.

```sh
portmaster -Bd sysutils/smartmontools
echo "DEVICESCAN -a -o on -S on -n standby,q -s (S/../.././02|L/../../6/03) -W 4,55,65 -m admin@example.org -M test" > /usr/local/etc/smartd.conf
sysrc smartd_enable="YES"
```

_smartd_ prüft beim Starten jetzt alle Platten, die er finden kann und sendet eine Testmail  an die definierte Adresse. Nebenbei erfährt man so nach einem Reboot auch, wann die Kiste wieder oben ist.



Jetzt ist der Server soweit erst ein mal eingerichtet. Diese Basiskonfiguration nutze ich für alle Systeme. Egal, ob er später ein Webserver, ein NAS, ein E-Mail-Server oder sonstwas werden soll. Die Absicherung mittels der Firewall _pf_ und die Einrichtung von _iocage_ werde ich in späteren Beiträgen erläutern.
