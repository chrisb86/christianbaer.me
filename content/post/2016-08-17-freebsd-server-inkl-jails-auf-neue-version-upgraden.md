---

date: 2016-08-17 23:32:08+00:00
draft: false
title: FreeBSD-Server inkl. ezjail-Jails auf neue Version upgraden
description: "FreeBSD-Server inkl. ezjail-Jails auf neue Version upgraden."
type: post
aliases:
    - /846-freebsd-server-inkl-jails-auf-neue-version-upgraden/
    - /2016/08/freebsd-server-inkl.-jails-auf-neue-version-upgraden/
tags:
- ezjail
- freebsd
- jails
- server
- shell
- upgrade
---

Ich bin gerade dabei, einen FreeBSD-Server, der als Host für diverse ezjail-Jails dient, auf eine neue FreeBSD-Version upzugraden. Als Referenz für mich dokumentiere ich das ganze hier einfach mal.

Das System läuft aktuell auf 10.1 und wird auf 10.3 gehoben. Bei späteren Upgrades müssen die Versionsnummern entsprechend angepasst werden.

Als erstes bringen wir das aktuell installierte System auf den letzten Stand und aktualisieren die Ports.

```sh
freebsd-update fetch
freebsd-update install
portsnap fetch update
```

Im nächsten Schritt laden wir die neuen Systemfiles herunter, installieren den neuen Kernel und rebooten das System.

    freebsd-update upgrade -r 10.3-RELEASE
    freebsd-update install
    shutdown -r now

Nach dem Reboot installieren wir die restlichen Systemfiles und rekompilieren alle installierten Ports. Anschließend starten wir den Server noch mal neu. Die Option _-m DISABLE_VULNERABILITIES=yes_ setze ich, damit ich nicht mitten im Upgrade aufhören muss, falls bei einem Port Sicherheitslücken bekannt sind. Temporär damit hinter der Firewall zu leben erscheint mir sinnvoller, als ein gebrickter Server. ;)
```sh
freebsd-update install
portmaster -af -m DISABLE_VULNERABILITIES=yes
shutdown -r now
```
Nach dem Reboot ist der Server an sich auf 10.3. Nun müssen noch die ezjail-Jails upgegradet werden.

Hierfür laden und installieren wir zunächst die aktualisierten Files für die Basejail und starten anschließend ezjail neu.

```sh
ezjail-admin install -r 10.3-RELEASE
env UNAME_r=10.3-RELEASE ezjail-admin update -s 10.1-RELEASE -U
ezjail-admin update -P
service ezjail-admin restart
```
Jetzt müssen wir nur noch in jeder einzelnen Jail die Ports rekompilieren und einmal neustarten.

```sh
portmaster -af -m DISABLE_VULNERABILITIES=yes
service -R
```

Das war's. Wenn keine Probleme auftreten und kann man damit in ner Stunde durch sein. Wenn mehrere Jails betrieben werden und viele Ports gebaut werden müssen, dauert es entsprechend länger.
