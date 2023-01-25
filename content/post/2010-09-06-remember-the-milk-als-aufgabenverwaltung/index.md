---

date: 2010-09-06 16:52:30+00:00
draft: false
title: Remember The Milk als Aufgabenverwaltung
type: post
aliases:
    -  /679-remember-the-milk-als-aufgabenverwaltung/
tags:
- aufgabenverwaltung
- gtd
- rtm
- todo
- ztd
---

{{< imgproc "screenshot-rtm" Resize "700x" >}} Screenshot von [Remember The Milk](https://rememberthemilk.com) {{< / imgproc >}}

RTM ist über den Browser von jedem Rechner aus erreichbar und bietet außerdem Apps für iPhone, Android und Blackberry an.

Eine Stärke von Remember The Milk ist das offene Konzept. Man wird nicht in irgendwelche Organisationssysteme gezwungen sondern kann sich anhand von Listen alles zusammen bauen, was man braucht.

Eine weitere Stärke sind die dynamischen Listen. Anhand von bestimmten Suchkriterien kann man sich hier verschiedenste Aufgaben dynamisch zusammen fassen lassen. Wo das praktisch ist, werde ich gleich noch zeigen.

Ansonsten kann man Aufgaben mit Tags versehen, Orte hinzufügen, an Andere delegieren und noch vieles mehr.

Die Standard-Liste nennt sich Eingang. Hier kommen alle Aufgaben rein, die entweder noch keiner Liste zugeordnet oder per E-Mail importiert wurden. Ich organisiere meine Aufgaben dann auf folgenden Listen: "Arbeit", "Persönlich", "Dieses Jahr" und "Irgendwann/Vielleicht".

Zusätzlich lege ich "Smartlists" an, welche meine Aufgaben nach bestimmten Kriterien filtern und sie mir anzeigen. #heute, #morgen und #überfällig sollten selbsterklärend sein. @büro und @home unterscheiden Aufgaben nach Büro (dienstlich) und zu Hause. @einkaufen zeigt mir alle Dinge, die ich besorgen muss und @telefon sind alle Telefonate die ich führen muss. Wenn ich bei einer Aufgabe auf Zuarbeit bzw. auf Rückmeldung von Dritten angewiesen bin, erscheint sie in der Liste @warten.

Die Liste #dash zeigt alle Aufgaben, die bisher noch im Eingang liegen, und denen ich keinen Ort und keinen Zieltermin zugewiesen habe.

So habe ich immer alle Aufgaben im Blick und kann kontext- bzw. ortsabhängig genau das anzeigen lassen, was ich im Augenblick erledigen kann.

Anbei noch ein Listing der Suchkriterien meiner Smartlists:

 * **#heute:** due:heute OR dueBefore:Today OR (dueAfter:"today 0:00" AND dueBefore:"Now") OR tag:"na"
 * **#morgen:** due:morgen
 * **#überfällig:** dueBefore:Today OR (dueAfter:"today 0:00" AND dueBefore:"Now")
 * **@büro:** location:@büro AND NOT tag:@warten
 * **@home:** location:@home AND NOT tag:@warten
 * **@einkaufen:** tag:@einkaufen
 * **@telefon:** tag:@telefon or name:anrufen and not tag:@warten
 * **@warten:** tag:@warten
 * **#dash:** (dueBefore:today OR due:never OR isLocated:false OR list:Eingang) NOT (list:"Irgendwann/Vielleicht" OR list:"Dieses Jahr" OR list:"@einkaufen")

Ich denke, das Prinzip wird klar und sollte sich auch auf andere Aufgabenverwaltungen übertragen lassen. Ich kann RTM nur empfehlen und bin seit zwei Jahren vollends zufrieden damit.
