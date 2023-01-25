---

date: 2011-02-06 09:48:38+00:00
draft: false
title: Aus Backup-Script mit rsync und growl wird fabula-backup
type: post
aliases:
    -  /684-aus-backup-script-mit-rsync-und-growl-wird-fabula-backup/


tags:
- backup
- fabula-backup
- git
- growl
- mac
- rsync
- time machine
---

In meinem Artikel "[Mac: Inkrementelle Backups mit rsync und growl](https://christianbaer.me/102-mac-inkrementelle-backups-mit-rsync-und-growl/)" habe ich letztens mein Backup-Script für den Mac veröffentlicht, welches mit rsync und growl bei mir Time Machine ersetzt und wesentlich mehr Möglichkeiten bietet.

Da ich jetzt noch ein Bisschen daran rumgeschraubt habe und auch für die Zukunft noch ein paar Dinge geplant sind, habe ich mich entschlossen, das Teil zu [GitHub](https://github.com/chrisb86/) zu schieben.

[Hier](https://github.com/chrisb86/fabula-backup) gibt's jetzt immer die aktuellste Version mit der Möglichkeit des Downloads und der Mitarbeit. Wenn es großartige Änderungen gibt, werde ich über neue Versionen auch hier berichten.

Aktuell sind wir bei Version 0.7.1 und es hat sich Folgendes getan:

  * Anstatt alles in einer log-Datei pro Ausführung zu dokumentieren, nutzt das Script jetzt den Syslog und schreibt ein Error-log nur, wenn Fehler aufgetreten sind. Es ist jetzt also näher an den Standardmethoden von OS X dran und müllt die Festplatte nicht mit Logfiles zu ;)

  * Die growl-Notifications sind jetzt nur sticky, wenn Fehler aufgetreten sind. Ansonsten verschwinden alle Benachrichtigungen, nach der von Euch eingestellten Zeit.

Für die Zukunft geplant ist noch eine stärkere Linux-Kompatibilität und evt. eine Setup-Prozedur o. Ä.
