---

date: 2012-09-28 08:55:15+00:00
draft: false
title: Für FileVault anderes Passwort nutzen als für Systemaccount
type: post
aliases:
    -  /567-fuer-filevault-anderes-passwort-nutzen-als-fuer-systemaccount/


tags:
- crypto
- filevault
- mac
- passwort
- security
- user
- verschlüsselung
---

Apples FileVault hat, mal abgesehen von den Sicherheitsbedenken die man prinzipiell gegenüber nichtoffener Kryptosoftware haben sollte, ein riesiges Problem.

Das Userpasswort entspricht dem Passwort zum Entschlüsseln der Festplatte.

Für Verschlüsselung nutze ich gerne Passwörter die an die 30 Zeichen lang sind, um ein einfaches Erraten so unwahrscheinlich wie möglich zu machen. Mein Userpasswort habe ich gerne etwas kürzer, da ich es öfter eingeben muss.

Apple stellt uns hier vor die Qual der Wahl. Bequemlichkeit oder Sicherheit? Es geht erst mal nur eins von beidem, da für die Verschlüsselung kein separates Passwort vergeben werden kann.

Über einen kleinen Umweg ist es aber doch möglich, ein langes Passwort als einzige Angriffsfläche zu setzen.

Hierfür sind zwei Verhaltensweisen von OS X bzw. FileVault ausschlaggebend.

 1. Neue User werden automatisch berechtigt, mit ihrem Passwort die Festplatte zu entschlüsseln
 2. Wird für einen bereits bestehenden User ein leeres Passwort gesetzt, wird ihm die Berechtigung zum entschlüsseln entzogen.

enn wir das beides kombinieren, tut sich folgender Weg auf. Wir legen einen neuen User mit einem sehr langen (sicheren) Passwort an. Dieser bekommt automatisch das Recht zum Entschlüsseln. Unserem eigenen User setzen wir kurzzeitig ein leeres Passwort und entziehen ihm diese Berechtigung. Wir können die Festplatte jetzt nur noch mit dem langen Passwort des neuen Users entschlüsseln. Wir werden dann als dieser User angemeldet, können uns wieder ausloggen und mit unserem "Arbeitsuser" wieder anmelden.

Ich arbeite mit dem Account _**chris**_. FileVault ist aktiviert und alles verschlüsselt. 

Ich lege jetzt in den Systemeinstellungen den User _**leia**_ an und vergebe ein sehr langes Passwort. Anschließend öffne ich das Terminal und tippe _passwd_ ein. Ich werde nach dem aktuellen Passwort gefragt und anschließend zwei mal nach dem Neuen. Die Frage nach dem Neuen bestätige ich einfach mit Return ohne eine Eingabe zu machen. Mein Passwort ist jetzt leer und ich kann die Festplatte nicht mehr entschlüsseln.

Dann führe ich _passwd_ noch mal aus, bestätige die Frage nach dem aktuellen Passwort mit Return, da es ja leer ist, und vergebe als neues Passwort jenes, welches ich vorher hatte.

Wenn ich jetzt neu starte, kann ich mich nur noch als _**leia**_ mit dem langen Passwort anmelden. Voilá, Ziel erfüllt!
