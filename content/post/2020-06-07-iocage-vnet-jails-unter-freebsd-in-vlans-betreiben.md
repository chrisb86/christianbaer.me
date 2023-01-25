---
title: "iocage VNET-Jails Unter FreeBSD in VLANs Betreiben"
date: 2020-06-07T12:16:03+02:00
draft: false
type: post
tags: ["FreeBSD","iocage","Jails","VLAN","VNET","VIMAGE","LAGG","LACP"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich habe einige Zeit damit verbracht, iocage VNET Jails und VLANs unter einen Hut zu bekommen. Da ich erfolgreich war, möchte ich meinen Weg hier dokumentieren.

Zuerst ein mal ein paar Infos zu meinem Setup.

Das ungetaggte Management-Netz hat das IP-Netz 192.168.1.1/24.

Zusätzlich gibt es mehrere getaggte VLANS:

- LAN 10.0.3.12/24 (VLAN 30)
- IoT 10.0.4.12/24 (VLAN 40)
- Guest 10.0.5.12/24 (VLAN 50)
- VOIP 10.0.6.12/24 (VLAN 60)
- DMZ 10.0.7.12/24 (VLAN 70)

Der Server verfügt über zwei NICs (_igb0_ und _igb1_).

Das Ziel ist, dass _igb0_ im Management-Netz hängt und z.B. der SSH-Server des Hosts darüber verfügbar ist. Das über den Switch schon das richtige Netz ankommt, ist hier nichts großartig zu konfigurieren.

_igb1_ soll als Interface für die iocage-Jails dienen. Der Port ist auf dem Switch als Trunk konfiguriert. Hier kommen also alle VLANs getagged an. Für die Jails möchte ich jeweils konfigurieren können, in welchem VLAN und dementsprechend auch welchem IP-Netz sie betrieben werden, um z.B. den Webserver in der DMZ und den Samba-Server im normalen LAN erreichbar zu machen.

Hierfür ist es zunächst notwendig, erst mal alles in der _/etc/rc.conf_ zu konfigurieren. Später konfigurieren wir noch die Jails.

## /etc/rc.conf

Als erstes setzen wir für den Host den Defaultrouter und den Nameserver aus dem untagged Management-Netz.

```sh
defaultrouter="192.168.1.1"
nameserver="192.168.1.1"
```

Als nächstes konfigurieren wir _igb0_ (welche im Management-Netz hängt) und vergeben hier eine IP (192.168.1.12).

```sh
ifconfig_igb0="inet 192.168.1.12/24 -rxcsum -rxcsum6 -txcsum -txcsum6 -lro -tso -vlanhwtso description Management"
```

Der Host ist nun regulär über 192.168.1.12 erreichbar, solange man im Management-Netz hängt, oder entsprechende Firewall-Regeln gesetzt hat. Bis hierhin erst mal nichts besonderes.

Widmen wir uns nun also _igb1_.

Zuerst konfigurieren wir das Interface, bringen es hoch, aber vergeben keine IP.

```sh
ifconfig_igb1="up -lro -tso4 -tso6 -vlanhwtso"
```

Im nächsten schritt definieren wir, welche VLANs wir auf der NIC sprechen wollen. Die Namen sind prinzipiell frei wählbar, eine einheitliche Namensgebung vereinfacht aber die Übersicht.

```sh
vlans_igb1="vlan30 vlan40 vlan50 vlan60 vlan70"
```

Jetzt müssen wir für jedes eben angelegt Netz noch definieren, in welches VLAN es gehört, welche IP das Interface erhalten soll (auch hier vergebe ich einfach die 12 in allen Netzen um es übersichtlich zu haben) und können noch eine Beschreibung eintragen, die z.B. von _ifconfig_ ausgegeben wird.

```sh
create_args_vlan30="vlan 30"
ifconfig_vlan30="inet 10.0.3.12/24"
ifconfig_vlan30_descr="LAN (VLAN 30)"

create_args_vlan40="vlan 40"
ifconfig_vlan40="inet 10.0.4.12/24"
ifconfig_vlan40_descr="IoT (VLAN 40)"

create_args_vlan50="vlan 50"
ifconfig_vlan50="inet 10.0.5.12/24"
ifconfig_vlan50_descr="Guest (VLAN 50)"

create_args_vlan60="vlan 60"
ifconfig_vlan60="inet 10.0.6.12/24"
ifconfig_vlan60_descr="VOIP (VLAN 60)"

create_args_vlan70="vlan 70"
ifconfig_vlan70="inet 10.0.7.12/24"
ifconfig_vlan70_descr="DMZ (VLAN 70)"
```

Da _iocage_ mit den Interfaces alleine noch nichts anfangen kann, müssen wir jetzt für jedes VLAN noch eine Bridge anlegen, welche dann später von den Jails genutzt wird. Auch hier gilt wieder: Einheitliche Namen erleichtern die Übersicht.

```sh
cloned_interfaces="bridge30 bridge40 bridge50 bridge60 bridge70"
ifconfig_bridge30="up addm vlan30"
ifconfig_bridge40="up addm vlan40"
ifconfig_bridge50="up addm vlan50"
ifconfig_bridge60="up addm vlan60"
ifconfig_bridge70="up addm vlan70"
```

Nach einem Reboot ist unsere Konfiguration geladen und aktiv.

## iocage Jails konfigurieren
Zu guterletzt müssen wir iocage noch beibringen, die Bridges zu nutzen. Das eben angesprochene Szenario, Webserver in der DMZ und Samba-Server im LAN würden wir wie folgt realisieren.

```sh
iocage set interfaces=vnet0:bridge30 samba
iocage set interfaces=vnet0:bridge70 www
```
Da iocage standardmäßig die Nameserver aus der _/etc/resolv.conf_ des Hosts an
die Jails weitergibt, und diese dann aus der Jail nicht erreichbar sind, da sie
ja in einem anderen Netz liegen, ist noch ein Bisschen Handarbeit notwendig.

```sh
iocage set defaultrouter="10.0.3.1" resolver="10.0.3.1" samba
iocage set defaultrouter="10.0.7.1" resolver="10.0.7.1" www
```

Somit haben wir für die Jail das entsprechende Gateway und den Resolver des
VLANs gesetzt und die Kommunikation sollte funktionieren.

Wenn die Jails neugestartet wurden, sind sie im richtigen Netz. Auf dem selben Weg können wir nun auch alle anderen Jails zu allen anderen VLANs hinzufügen.

## Linkaggregation mit LACP

Wenn wir jetzt aber statt einer einzelnen NIC für die Jails gerne mehrere NICs
bündeln würden, um die Bandbreite zu erhöhen, können wir das auch mit minimalen
Änderungen tun.

Ich habe im Server noch eine andere Karte _em0_ stecken und möchte diese für das Management-Netz
nutzen. So habe ich _igb0_ und _igb1_ frei, um sie über LACP zu bündeln und den
Jails zur Verfüfung zu stellen.

Zuerst konfigurieren wir _em0_ genau so, wie wir es oben mit _igb0_ gemacht
haben.

```sh
ifconfig_em0="inet 192.168.1.12/24 -rxcsum -rxcsum6 -txcsum -txcsum6 -lro -tso -vlanhwtso description Management"
```

Als nächstes machen wir dem System _igb_0 und _igb1_ bekannt und bündeln diese
im Interface _lagg0_.

```sh
ifconfig_igb0="up -lro -tso4 -tso6 -vlanhwtso"
ifconfig_igb1="up -lro -tso4 -tso6 -vlanhwtso"
```

Und zum Schluss definieren wir dann die VLANs statt auf _igb1_ eben auf _lagg0_.

```sh
cloned_interfaces="lagg0 bridge30 bridge40 bridge50 bridge60 bridge70"

ifconfig_lagg0="laggproto lacp laggport igb0 laggport igb1"

vlans_lagg0="vlan30 vlan40 vlan50 vlan60 vlan70"
```

An der Config der Jails müssen wir nichts ändern, da diese ja die bridges nutzen
und wir in die Bridges die VLAN-Interfaces packen, und nicht die NICs direkt.

Den Jails steht jetzt die gebündlete Bandbreite von 2 GBit-Nics zur Verfügung.
Jede Verbindung nutzt weiterhin nur eine NIC und kann somit maximal 1 GBit
erreichen. Mehrere Verbindungen verteilen sich dann aber auf die Karten und
können dann zusammen eben theoretisch 2 GBit erreichen. Man könnte dies auch
noch mit zusätzlichen NICs erweitern, falls man sie hat und muss sie nur hochbringen und
ins _lagg0_ packen.
