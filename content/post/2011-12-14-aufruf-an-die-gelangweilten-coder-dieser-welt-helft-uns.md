---

date: 2011-12-14 12:09:18+00:00
draft: false
title: 'Aufruf an die gelangweilten Coder dieser Welt: Helft uns!'
type: post
aliases:
    -  /398-aufruf-an-die-gelangweilten-coder-dieser-welt-helft-uns/


tags:
- aufruf
- coding
- hacker
- kontakte
- software
- verwaltung
---

Ich habe ein Problem und weiß, dass es zumindest einigen anderen Menschen genau so geht.

Als politisch aktiver Mensch lerne ich ständig und überall auf der Welt Menschen kennen. Ihre Kontaktdaten wandern in mein Adressbuch und gesellen sich dort zu 700 anderen. Ich kann die Organisation angeben, kann auch Notizen hinzufügen und eintragen, wo sie wohnen oder arbeiten. So entsteht relativ schnell ein sehr unübersichtliches Netzwerk. Überblick bekomme ich nur, wenn ich mir alle Kontakte einzeln anschaue und versuche, irgendwelche Strukturen nachzuvollziehen. Das ist sehr mühselig und zeitaufwendig.

Wenn ich z.B. einen Kontakt Anja Musterfrau habe, weiß ich, dass sie in Pinneberg wohnt wohnt, wie ich sie erreichen kann und dass sie bei einer Altenpflegeeinrichtung arbeitet. Vielleicht erinnere ich mich auch noch daran, dass sie in Hamburg in einer Gruppe aktiv ist, die sich gegen Gentrifizierung engagiert. Dass sie beim DGB und in der Tierrechtsszene aktiv ist, vergesse ich aber immer.

Nun plane ich z.B. eine dreitägige Fahrt nach Hamburg und möchte dort einige Menschen treffen, um meine Netzwerke zu pflegen. Mir fehlt ein Überblick, mit wem ich mich in Hamburg treffen könnte. Welche Kontakte machen aufgrund meiner aktuell laufenden Projekte Sinn?

Oder ich möchte in den Gewerkschaften eine Kampagne initiieren, die zum Ziel hat, dass die eine Gesetzesinitiative gestartet wird, die eine Kenzeichnungsflicht für Lebensmittel fordert, die Vegetarier_innen ermöglicht, auf den ersten Blick zu sehen, ob tierische Bestandteile in einem Lebensmittel verwendet wurden. Wo habe ich in Deutschland Kontakte, die ich mit einspannen könnte?

Ihr seht, das ist alles nicht einfach. Was will ich also, um mir das alles zu vereinfachen und das Netzwerken systematischer betreiben zu können?

Ich möchte Kontakten mehrere Organisationen zuweisen können
Bei Anja: z.B. Altenpflegeinrichtung Kunz, DGB, Recht auf Stadt, Animal Liberation Front

 * Ich möchte Kontakten mehrere Organisationen zuweisen können (bei Anja: z.B. Altenpflegeinrichtung Kunz, DGB, Recht auf Stadt, Animal Liberation Front)
 * Ich möchte Kontakte thematisch taggen können (bei Anja z.B. gewerkschaft, antifa, gentrification, tierrechte, altenpflege)
 * Ich möchte unabhängig von den Adressen im Adressbuch auch Orte hinzufügen können (Anja hat ihren politischen Wirkungskreis in Hamburg und nicht in Pinneberg, wo sie wohnt und arbeitet. Das muss ersichtlich sein.)
 * Die Kontakte lassen sich dann nach allen möglichen Kriterien filtern
 * Darstellung der Menschen pro Ort auf einer Karte
 * Verknüpfungd der Menschen in Mindmaps um Netzwerke darzustellen (und die Map dann auch als Overlay auf der Karte)
 * Ich kann Kontakten weitere Kontaktmöglichkeiten hinzufügen, die nicht in einer Standard-vCard vorhanden sind (JID, GPG-Key, in welchen IRC-Channels hängen die Menschen rum etc.)
 * All diese Informationen werden am Besten in den Kontakten im Adressbuch selbst gespeichert, um sie damit auch auf dem Exchange, LDAP, SyncML-Server liegen zu haben und um Kontakte nicht in zwei Systemen pflegen zu müssen
 * Sollte Plattformunabhängig funktionieren und vorhandene Standards nutzen

Ja, das ist ne ganze Menge und es gibt mit Sicherheit auch noch mehr denkbare Anwendungsfälle und Kriterien. Ich hoffe aber, ihr versteht, worauf ich hinaus will.

Zur möglichen Umsetzung habe ich mir auch schon ein paar Gedanken gemacht.

Eine denkbare Möglichkeit wäre es, das Notizfeld einer vCard zu nutzen. Die Informationen könnten dann strukturiert als XML-Tree gespeichert werden. Ein Nachteil ist jedoch die schlechte Lesbarkeit z.B. mit Smartphones.

Eine andere denkbare Möglichkeit wäre eine eigene Markup-Language (#tag, @ort, §organisation etc.), die eine einfache Lesbarkeit am Smartphone ermöglicht und sich trotzdem gut parsen lässt.

Wenn Ihr nun also Lust habt, mir und dem Rest der Menschheit etwas Gutes zu tun. Dann fangt an irgendetwas in diese Richtung zu coden. Jeder kleine Schritt ist besser, als die jetzige Situation.

Ich bin bereit dazu, mit Ideen und Kreativität meinen Teil dazu beizutragen. Ich stelle Webspace zur Verfügung und tue sonst alles was nötig ist, um zu unterstützen. Aber bitte helft uns!
