---

date: 2013-02-14 16:13:38+00:00
draft: false
title: Selbstbau-NAS mit FreeBSD
type: post
aliases:
    -  /630-selbstbau-nas-mit-freebsd/


tags:
- afp
- atom
- diy
- freebsd
- nas
- passivkühlung
- raid
- samba
- server
- storage
- time machine
---

Wie in [Ausgabe 2 von skrupuloes](http://skrupuloes.de/podcast/skr002-das-nas-ist-voll-und-die-telekom-kann-manchmal-doch-was/) zu hören war, hatte ich Probleme mit dem Speicherplatz auf meinem NAS. Die [Synology Diskstation 211J](http://www.synology.de/products/product.php?product_name=DS211j&lang=deu) hat nur Platz für zwei Platten, die ich aus Redundanzgründen gespiegelt habe. Ich hatte also effektiv 2 TB Platz. Da die Diskstation auch meine Boxee-Box, Raspberry Pi mit XBMC und diverse iDevices mit Mediendateien versorgt hat, war der Platz relativ schnell voll, wenn man die Time Machine-Backups für zwei MacBooks dazu rechnet. Es musste also etwas neues her.

Die fertigen Lösungen, die es auf dem Markt gibt waren mir alle zu unflexibel und mit Platz für mind. vier Festplatten auch relativ schnell relativ teuer. Ich entschied mich also, etwas selbst zu bauen.

Nach ein wenig Recherche entschied ich mich für folgende Komponenten:

 * **Mainboard**: [ASUS C60M1-I](http://www.asus.com/Motherboard/C60M1I/)
 * **Gehäuse**: [Fractal Design Array R2](http://www.fractal-design.com/?view=product&category=9&prod=43)
 * **RAM**: Corsair XMS3 PC-133 8GB (CL9)
 * **Festplatten**:
   - Western Digital WD20EZRX Green 2TB
   - 320 GB Hitachi 2,5" HDD aus MacBook Pro

Das Mainboard ist passivgekühlt, kommt mit einem AMD Fusion Dualcore mit 1GHz, Gigabit-LAN und 6 SATA-Ports. Dazu habe ich 8 GB RAM verbaut (man weiß ja nie…). Gespeichert wird auf vier 2 TB-Platten und einer 320 GB-Platte, die ich noch aus meinem MacBook rumliegen hatte. Das Gehäuse ist extra für den Einsatz als NAS entwickelt worden. Es kommt komplett mit einem großen Gehäuse-Lüfter, 300 W-Netzteil und bietet sowohl einen herausnehmbaren Festplattenkäfig für bis zu sechs Platten und die Möglichkeit, zusätzlich eine 2,5"-Platte zu verbauen.

Da ich aus Gründen der Datensicherheit gerne [ZFS](http://de.wikipedia.org/wiki/ZFS_(Dateisystem)) nutzen wollte, bin ich nun gezwungen, nicht mehr Linux zu benutzen. Da mir fertige NAS-Distributionen zu unflexibel sind, entschied ich mich, mal etwas neues zu wagen und jetzt läuft hier ein schickes [FreeBSD](http://www.freebsd.org).

Als Linux-Umsteiger war FreeBSD kurzzeitig ungewohnt, aber mittlerweile bin ich recht gut drin und lerne die diversen Vorzüge bezüglich Software-Verwaltung mit Ports, Konfigurationsdatein etc. zu schätzen.

Die vier großen Platten laufen als RAIDZ1 (vergleichbar mit RAID5) und bieten mir somit knapp 6 TB Speicherplatz und eine mögliche Wiederherstellung, falls eine Platte ausfällt. Wenn der Speicherplatz knapp wird, kann ich noch zwei weitere Platten verbauen und das RAID einfach erweitern. Die 2,5"-Platte nutze ich als Systemplatte und habe hierauf das BSD installiert.

Alles in allem habe ich jetzt für vergleichsweise wenig Geld ein kleines, Leistungsstarkes, stromsparendes und flexibel einsetzbares System, das auch noch Spaß beim Herumexperimentieren mit einem echten UNIX gibt ;-)
