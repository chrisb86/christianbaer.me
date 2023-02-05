---
title: "Meine Infrastruktur 2020"
date: 2020-05-03T11:29:46+02:00
draft: false
type: post
tags: ["selfhosting","infrastruktur","unifi","FreeBSD"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich hatte schon länger vor, mal etwas über meine Infrastruktur zu schreiben.
Jetzt nutze ich die Zeit einfach mal.

Prinzipiell versuche ich, so viel es geht selbst zu betreiben, um nicht auf
externe Dienste angewiesen zu sein, die mit meinen Daten Geld verdienen wollen.
Zu diesem Zwecke betreibe ich aktuell vier Server an vier Standorten.

Ich betreibe die Dienste für mich, für Freunde, die Familie und befreundete
Organisationen.

Die Server benenne ich nach den Companions von Doctor Who. Ich mag Doctor Who.
Und viele der Comapnions. Und die Liste an Möglichen Namen ist auch sehr lang.
Lasst uns also starten.

## Meine Hosts

Aktuell betreibe ich _donna_, _rory_, _rose_ und _amy_ (und _river_ als Gateway zu Hause).
Auf allen Servern läuft FreeBSD auf einer ZFS-Konfiguration. Die Jails betreibe
ich mit iocage und manage sie mit meine Script jailer.sh. Die Webserver laufen
auf nginx und ich manage sie mit meinem Sccript ngineerx. Zum Monitoring setze
ich auf allen Servern monit ein, was auch dafür sorgt, dass Dienste neu
gestartet werden, falls sie mal Probleme machen sollten.

### donna

_donna_ steht bei uns im Keller. Er beinhaltet drei Unterschiedliche zpools. Zwei
gemirrorte SSDs für das Betriebssystem und Daten, die flüchtig sein können
(Caches etc), zwei gemirrorte SSDs für die Jails und Datenbanken etc, wo es auf
Geschwingkeit ankommt und 6 ordinäre Festplatten in einem RAIDZ2, auf dem die
großen Datenmengen Liegen, bei denen es nicht auf eine Sekunde ankommt.

Auf donna laufen aktuell 10 Jails:

- **gitea**: Das ist der [Gitea](https://gitea.io)-Server, der meine
  Git-Repositories unter
  [https://git.debilux.org/chbaer](https://git.debilux.org/chbaer) hostet
- **redis**: Die [redis](https://redis.io/)-Datenbank als Cache für Gitea und
  Nextcloud
- **samba**: Der [Samba](https://www.samba.org/)-Server, der im lokalen Netz die
  Daten zur Verfüfung stellt und als Backup-Target für TimeMachine dient.

- **sql**: Die [MariaDB](https://mariadb.org/)-Datenbank, die von Nextcloud
  benutzt wird.

- **unbound**: [unbound](https://nlnetlabs.nl/projects/unbound/about/) als lokaler
  DNS-Server und Resolver für das heimische Netz.

- **plex**: Der [Plex](https://plex.tv)-Server streamt Medien an Familie und
  Freunde.
- **rmbackup**: Diese Jail zieht regelmäßig Backups von allen Servern mithilfe von
  [rmbackup](https://github.com/chrisb86/rmbackup)
- **sbbackup**: [sbbackup](https://git.debilux.org/chbaer/sbbackup) ist ein
  kleines Script, dass die Home-Directories auf donna regelmäßig offsite in eine
  Hetzner Storage-Box sichert.

- **tautulli**: [Tautulli](https://tautulli.com/) ist ein Monitoring-Tool für den
  PLEX-Server.

- **www**: [nginx](https://www.nginx.com/) dient als reverse Proxy für Gitea,
  hostet die Nextcloud und stellt mir Zugriff auf Administrationsoberflächen zur
  Verfügung.

### rose

_rose_ ist ein ein Cloud-Server von Hetzner, der in Falkenstein betrieben wird.

Aktuell laufen auf rose 10 Jails:

- **ftp**: Hier läuft ein [PureFTPd](https://www.pureftpd.org/project/pure-ftpd/)
  als FTP-Server meine Webprojekte.
- **memcache**: [memached](https://memcached.org/) dient als Cache für Roundcube.
- **nsd**: Hier läuft ein [nsd](https://www.nlnetlabs.nl/projects/nsd/) als
  Master-Nameserver unter ns1.dblx.io

- **solr**: [Solr](https://lucene.apache.org/solr/) dient als Datenbank für die
  serverseitige Suche für den Dovocot-IMAP-Server
- **unifi**: Der [Controller](https://www.ui.com/software/) für meine
  Unifi-Netzwerke.
  **mail**: Hier läuft [opensmtpd](https://opensmtpd.org/) als SMTP-Server und mx
  unter mx1.dblx.io, Dovecot als IMAP-Server mit sieve zur Filterung sowie rspamd
  als Spamfilter.

- **ns**: Wie zu Hause auch, ein unbound-Server als DNS resolver für die Jails.

- **redis**: Als Cache für rspamd und wallabag.
- **sql**: MariaDB für die Webprojekte, sowie roundcube, FTP-Server, ttrss und
  wallabag.
- **www**: nginx als reverse Proxy für den UniFi-Controller, sowie als Host für
  ttrss, wallabag, https://ip.dblx.io, https://christianbaer.me, Autoconfig für
  den Mail-Server und Seiten befreundeter Organisationen.

### rory

_rory_ ist ein ein Cloud-Server von Hetzner, der in Nürnberg betrieben wird.

Hier laufen nur zwei Jails:

- **nsd**: nsd als secondary Nameserver unter ns2.dblx.io
- **smtpd**: opensmtpd als Backup-MX unter mx2.dblx.io

### amy

_amy_ ist ein ein Cloud-Server von Hetzner, der in Helsinki betrieben wird.

Hier laufen nur zwei Jails:

- **nsd**: nsd als dritter Nameserver unter ns3.dblx.io
- **smtpd**: opensmtpd als Backup-MX unter mx3.dblx.io

### river und Heimnetzwerk

_river_ ist ein UniFi USG 4 Pro und Teil des UniFi-Setups, das ich zu Hause
betreibe. Dazu gesellen sich noch 6 Access Points im Haus und im Garten, ein
24-Port PoE-Switch im Keller, ein 5-Port USW Flex Mini auf meinem Schreibtisch
und eine Fritz-Box als SIP-Client für das Festnetztelefon, dass nie benutzt
wird.

Das Netzwerk ist in verschiedene WLANs und VLANs für Management, LAN, Telefonie,
Gäste und iOT-Geräte aufgeteilt.

Als ISP setzen wir auf die Telekom, welche uns eine 100 MBit-Leitung bei innogy
angemietet hat. Durch diese Kombination haben wir zu Hause leider kein IPv6
mehr, aber knapp 95 MBit Downstream und 38 MBit Upstream, was mir dann ein
Bisschen wichtiger war.

## Erfahrungen

Alles in allem bin ich sehr zufrieden. Die Cloud-Hosts bei Hetzner sind
vergleichsweise günstig für die Leistung. Das Setup bietet die notewendige
Redundanz und die wirklich wichtigen Dienste sind auch zu Hause erreichbar, wenn
das Internet mal nicht laufen sollte. Natürlcih könnte man die Cloud-Server noch
auf mehrere Anbieter verteilen, um wirklich sicher zu gehen, aber der Aufwand
rechtfertigt für mich den Nutzen nicht.

Bei meiner Softwareauswahl gehe ich gerne auf Nummer sicher und nehme gut
abgehangene Software, die ein gewisses Security-Standing hat und habe wenig Lust
auf Experimente, da der Kram ja in erster Linie laufen soll und ich meine
Produktivsysteme vermissen würde, wenn sie nicht mehr da sind.
