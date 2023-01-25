---
title: "macOS: In unbekannten WLANs automatisch mit VPN verbinden"
date: 2019-04-13T22:27:45+02:00
draft: false
type: post
tags: ["macOS","l2tp", "VPN"]
description: "In macOS mittels VPN Monitor automatisch einen Tunnel aufbauen, wenn man in fremden WLANs unterwegs ist."
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

In meinem [Beitrag zu iOS]({{< ref "2018-03-24-ios-in-unbekannten-wlans-automatisch-mit-vpn-verbinden.md" >}}) habe ich beschrieben, wie ich mein iPhone dazu bringe, sich in unbekannten WLANs automatisch mit meinem L2TP-VPN zu Hause zu verbinden, um unterwegs nie ungeschützt zu sein.

Für mein MacBook wollte ich schon länger eine ähnliche Funktion haben und habe viele Versuche unternommen, mir das irgendwie zurecht zu scripten. [VPN Monitor](https://itunes.apple.com/us/app/vpn-monitor/id887410814?mt=12), eine App, welche ich vor einigen Jahren mal gekauft habe, hat diese Funktion irgendwann in der Zwischenzeit erhalten.

> VPN Monitor is a status bar application to monitor and automatically reconnect a dropped VPN connection. When additional VPN services are configured, VPN Monitor will use these services as a fallback option in case the VPN server is down.

Die App lebt in der Statusbar und sorgt dafür, dass immer eine VPN-Verbindung aufgebaut wird, wenn sie läuft. Bisher musste ich unterwegs daran denken, sie zu starten. Jetzt kann man sichere WLANs definieren. In Netzwerken, welche in dieser Whitelist aufgeführt werden, wird kein VPN-Tunnel aufgebaut. Ich habe sie jetzt also im Autostart, mein eigenes WLAN als Ausnahme hinzugefügt und bin zu Hause ohne VPN und in fremden Netzen eben mit Verbunden.

Man sollte beachten, dass die App keine Verbindungen blockt. Wenn man also, warum auch immer, nicht mit dem VPN verbunden ist, geht sämtlicher Traffic ungetunnelt über das jeweilige Netz. Hierfür habe ich mir eine umfangreiche Little Snitch-Config gebaut. Diese erläutere ich irgendwann mal in einem eigenen Beitrag.

Bisher tut VPN Monitor, was es soll, und ist auf jeden Fall eine Empfehlung wert. Für OpenVPN-Tunnel ist [Tunnelblick](https://tunnelblick.net/) eine sehr gute Alternative.

