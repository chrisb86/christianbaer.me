---

date: 2018-03-24 12:21:59+00:00
draft: false
title: 'iOS: In unbekannten WLANs automatisch mit VPN verbinden'
type: post
aliases:
    -  /902-ios-in-unbekannten-wlans-automatisch-mit-vpn-verbinden/
tags : ["iOS", "l2tp", "VPN"]
---

Mit VPN-Verbindungens ist es, wie mit Backups. Meistens benötigt man sie, wenn man vorher nicht daran gedacht hat, sie zu erstellen.

Ich bin viel unterwegs und häufig in fremden oder offenen WLANs eingeloggt. Prinzipiell bin ich in solchen Situationen, wenn möglich, am Liebsten mit meinem heimischen VPN verbunden.

Lange Zeit nutzte ich ich nur aus einem einzigen Grund OpenVPN: Die iOS-App bietet eine Möglichkeit, das VPN anzuknipsen und iOS stellt die Verbindung immer wieder her, wenn sie abgebrochen wurde. Dies ist wenig elegant und OpenVPN relativ komplex. Ich hatte also keine Lust mehr darauf und musste bisher ja auch immer daran denken, das VPN auf dem iPhone explizit anzuschalten. Ich war also entweder nicht in WLANs oder dann selten in meinem VPN.

Nach der Umstellung auf meinen [EdgeRouter und dem Switch auf L2TP](https://christianbaer.me/891-telekom-vdsl-und-entertain-mit-draytek-vigor130-und-ubiquiti-edgerouter-x/) als VPN-Standard las ich davon, dass man mit iOS-Profilen die Möglichkeit hat, WLANs zu whitelisten und bei allen anderen WLANs automatisch eine VPN-Verbindung aufzubauen. Nach einer Suche auf GitHub bin ich auf ein höchst praktisches Projekt von [Kris Linquist](http://www.linquist.com/) gestoßen. [iOS-VPN-Autoconnect](https://github.com/klinquist/iOS-VPN-Autoconnect) bietet eine schlanke HTML-Seite, die ein paar Daten abfragt und lokal per JavaScript eine entsprechende Profildatei erstellt. Diese habe ich per AirDrop auf mein Telefon geabeamed und bin nun immer im VPN, wenn ich in einem anderen, als meinem heimischen WLAN eingeloggt bin. Das ist sehr simpel und funktioniert bisher zuverlässig.

Wenn es nicht funktionierte, lag es bisher an schlechten WLANs oder mangelnder Internetkonnektivität. In diesen fällen war aber immer das WLAN auch ohne VPN nicht wirklich nutzbar und ich bin auf LTE ausgewichen.
