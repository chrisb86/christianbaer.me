---
title: "Von GitHub zu Gitea"
date: 2020-05-02T23:35:23+02:00
draft: false
type: post
tags: ["github","gitea","git","selfhosted"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich versuche, wo immer es nur geht, nicht auf externe Dienste angewiesen zu
sein.

Einen Schritt, den ich schon seit längerer Zeit gehen wollte, ist meine Projekte
von [GitHub](https://github.com/chrisb86) wegzubekommen, beziehungsweise einen eigenen Git-Server zu betreiben
und GitHub nur noch als Mirror zu nutzen.

Vor ein paar Wochen bin ich dann auf [Gitea](https://gitea.io/) gestoßen. Gitea ist ein
offensichtlicher Clone von GitHub, in Go geschrieben und lässt sich
dementsprechend als einfaches Binary ziemlich easy installieren.

{{< imgproc gitea.png Resize "700x png" >}} Screenshot von Gitea {{< /imgproc >}}

Ich habe es jetzt auf meinem Heimserver in eine Jail verfrachtet und einen nginx
als Reverse-Proxy davor geschaltet.

Die Inbetriebnahme war schmerzfrei und es tut, was es soll. In den kommenden
Wochen werde ich jetzt Stück für Stück meine Repos auf [git.debilux.org/chbaer](https://git.debilux.org/chbaer) umziehen.
