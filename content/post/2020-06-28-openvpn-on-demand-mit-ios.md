---
title: "OpenVPN on demand mit iOS"
date: 2020-06-28T17:00:11+02:00
draft: false
type: post
tags: ["iOS","OpenVPN","VPN","OPNsense"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich war für meine  VPN-Lösung jahrelang Nutzer von IPSec, da dies zuerst von der Fritz!Box  und dann die letzten Jahre vom EdgeRouter und zuletzt vom USG direkt  unterstützt wurde.

Diverse Gründe haben mich aber in den letzten Wochen zum Umstieg auf einen DIY-Router mit [OPNsense](https://opnsense.org/) bewegt.

Da IPSec irgendwie immer eine Krücke ist und OpenVPN direkt von  OPNsense unterstützt wird und viele Vorteile bringt, habe ich mich  entschlossen, mit dem Router auch den VPN-Server zu wechseln.

Wenn man diesen in OPNsense einrichtet und einen User inkl. Zertifikaten etc. anlegt, gibt es die Möglichkeit, das entsprechende ovpn-File zur Konfiuration der Clients direkt aus OPNsense herunter zu laden.

Wie ich [hier](https://christianbaer.me/post/2018/03/ios-in-unbekannten-wlans-automatisch-mit-vpn-verbinden/) beschrieben habe, nutzte ich mit IPsec die Möglichkeit, unter iOS eine VPN-Verbindung aufzubauen, wenn ich mich außerhalb vertrauenswürdiger WLANs bewegte. So einen einfachen Konfigurator gibt es für OpenVPN leider nicht. Auch der offizielle OpenVPN-Client für iOS bietet diese Konfigurationsmöglichkeiten nicht.

Durch Zufall bin ich dann aber über [Passepartout](https://passepartoutvpn.app/), einen alternativen iOS-OpenVPN-Client, gestoßen. Dieser bietet genau die Möglichkeiten, die gesucht habe.

Ich kann vertrauenswürdige WLANs definieren, angeben, ob das Mobilfunknetz mit oder ohne VPN genutzt werden soll und einfach mein Configfile aus OPNsense importieren. Und er ist [Open Source](https://github.com/passepartoutvpn).

Ich habe ihn jetzt ein paar Wochen im Einsatz und muss sagen, er macht was er soll und ich bin sehr zufrieden.

