---

date: 2016-01-31 21:59:41+00:00
draft: false
title: Mehrere SSH-Connections zum selben Host beschleunigen
type: post
aliases:
    -  /786-mehrere-ssh-connections-zum-selben-host-beschleunigen/


tags:
- multiplexing
- server
- ssh
---

Manchmal kommt es vor, dass man mehrere SSH-Connections zum selben Host aufbauen muss, um z.B. gleichzeit etwas auszuführen und parallel dazu, die Logfiles zu sehen.

Bei jedem Verbindungsaufbau muss die Verbindung inkl. dem ganzen Overhead neu aufgebaut werden, was Zeit kostet und u.U. dazu führt, dass man Passwörter usw. erneut eingeben muss.

SSH bietet die Möglichkeit, in solchen Fällen die bestehende Verbindung einfach erneut zu benutzen.

Füge folgendes in die _.ssh/config_ ein:

    Host *
    ControlMaster auto
    ControlPath ~/.ssh/control-%h-%p-%r
    ControlPersist 600

_Host *_ sorgt dafür, dass die folgenden Bedingungen auf alle Verbindungen angewandt werden. Wenn Du statt dem * einen Hostnamen (z.B. github.com) angibst, beziehen sich die Settings nur auf die Verbindungen zu eben jenem.

_ControlMaster auto_ sorgt dafür, dass bestehende Connections automatisch verwendet werden.

_ControlPath ~/.ssh/control-%h-%p-%r_ legt für jede Verbindung einen Control-Socket unter ~/.ssh an. Diesen Pfad kannst Du frei wählen. Er muss jedoch bereits existieren.

_ControlPersist 600_ hält die Verbindung für 10 Minuten offen, nachdem die erste Verbindung (der Master) geschlossen wurde. Ohne diese Option werden alle Connections gekappt, sobald der Master geschlossen wird.

In der [Manpage zu ssh_config](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man5/ssh_config.5) gibt es noch viele weitere Optionen und Konfigurationsbeispiele.
