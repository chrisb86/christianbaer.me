---

date: 2015-11-20 20:01:03+00:00
draft: false
title: System-Monitoring mit Glances
type: post
aliases:
    -  /762-system-monitoring-mit-glances/


tags:
- server
- shell
- software
- system monitoring
---

[Glances](https://nicolargo.github.io/glances/) ist ein ziemlich schickes System-Monitoring-Tool für die Shell.

Es ist in Python geschrieben, für alle gängigen Betriebssysteme verfügbar und so eine Art (h)top auf Steroiden.

Es zeigt u.A. CPU- und Speicher-Auslastung, Load, Prozesse, Auslastung der Netzwerk-Interfaces, Disk I/O, Temperaturen und die Filesystembelegung an. So hat man alles auf einen Blick, was man sich sonst mit vielen verschiedenen Tools zusammen basteln müsste.

Es bietet eine API und kann die Daten z.B. an einen StatsD weitergeben oder per Web-Interface zugänglich machen. Den Source Code, Instruktionen zum Schreiben von Plugins, sowie Installationsanleitungen gibt's auf [GitHub](https://github.com/nicolargo/glances).

{{< imgproc "screenshot-glances.png" Resize "700x" >}} Screenshot von Glances auf einem meiner Server {{< / imgproc >}}

Ich habe Glances jetzt seit ein paar Tagen auf allen Servern und dem MacBook im Einsatz und mag es.
