---
title: "caldav2todoist - Todoist mit Siri ohne IFTTT"
date: 2020-09-23T21:31:20+02:00
draft: false
type: post
tags: ["shell","Todoist","CalDAV","nextcloud","Siri","Apple"]
Categories: ["Allgemein"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich bin langjähriger Nutzer von [Todoist](https://todoist.com) und versuche möglichst viele Dinge (mit meiner Nextcloud) selbst zu hosten.

Zusätzlich bin ich voll im Apple-Ökosystem zu Hause und genieße es, Aufgaben über _Siri_ in meine Watch, mein iPhone oder auch im Auto über CarPlay zu diktieren.

Der von Todoist empfohlene Weg, Siri und Todoist zu verbinden, sieht vor, dass die Aufgaben in einer Reminders-Liste landen und man den Dienst [IFTTT](https://ifttt.com) nutzt, um diese dann in Todoist erstellen zu lassen.

Das hat vor ein paar Jahren mal eine Zeit lang mehr oder weniger funktioniert. Mindestens seit einem Jahr aber bei mir nicht mehr, und wenn, nicht zuverlässig. Zudem ist IFTTT eben wieder ein externer Dienst, den ich mit in die Kette nehmen muss und der Zugriff auf meine Daten hat.

Ich überlegte also schon die ganze Zeit, wie ich das Thema anders lösen kann und war auch schon auf der Suche nach einem anderen Todolisten-Dienst.

Gestern habe ich mir dann mal angeschaut, wie man mit _curl_ CalDAV-Server abfragen und die Todoist-API bedienen kann. Nach ein Bisschen rumprobieren ist es mir dann gelungen, und [caldav2todoist](https://git.debilux.org/chbaer/caldav2todoist) ist entstanden.

Dieses Script läuft in _/bin/sh_ und hat keine externen Abhängigkeiten (_curl_ und _uuidgen_ sollten auf allen modernen Systemen ja vorhanden sein).

Es ruft von einem CalDAV-Kalender die Tasks ab, die seit dem letzten Abruf erstellt wurden. Diese werden in einer Datei zwischengespeichert und dann Stück für Stück in die Todoist-Inbox gepusht. Falls das fehlschlägt, bleiben sie gespeichert und sind beim nächsten Aufruf noch mal dran.

Dieses Script läuft bei mir jetzt minütlich per _cron_ und mein Problem ist gelöst.

Nebenbei habe ich noch einen [Bug in nextcloud](https://github.com/nextcloud/server/issues/23011#event-3796562061) bzw. der Tasks-App gefunden. 
Wenn man diese nutzt, um über das Webinterface eine Aufgabe zu erstellen, werden diese mit der Zeitzone des Servers für das CREATED-Feld und alle anderen zeitrelevanten Dinge gespeichert. Wenn man sie anders, wie in meinem Fall über Siri oder die Reminders-App direkt, erstellt, wird UTC als Zeitzone benutzt, was auch [RFC 4791](https://tools.ietf.org/html/rfc4791) fordert.

Dadurch fallen bei caldav2todoist Tasks durchs Raster oder werden doppelt erstellt, da ich immer von UTC ausgehe.

Es stellt sich heraus, dass die Tasks-App für nextcloud einfach [noch nicht mit Zeitzonen umgehen kann](https://github.com/nextcloud/server/issues/23011#issuecomment-697175561).