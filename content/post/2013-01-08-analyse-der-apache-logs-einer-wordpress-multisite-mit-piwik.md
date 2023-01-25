---

date: 2013-01-08 11:02:58+00:00
draft: false
title: Analyse der Apache-Logs einer Wordpress-Multisite mit Piwik
type: post
aliases:
    -  /612-analyse-der-apache-logs-einer-wordpress-multisite-mit-piwik/


tags:
- analyse
- apache
- cron
- logs
- piwik
- podcast
- script
- shell
- wordpress
---

Ich habe gestern meine diversen Projekte, die auf Wordpress laufen endlich mal in eine [Multisite-Installation](http://codex.wordpress.org/Create_A_Network) gepackt. Das heißt, alle Blogs sind weiterhin ganz normal erreichbar, ich muss aber nur noch eine Wordpressinstallation mit Plugins etc. pflegen und habe somit weniger Administrationsaufwand.
Bisher habe ich die Nutzungszahlen der Seiten mit Piwik und dem dazugehörigen Javascript-Snippet getrackt. Das hat dort anscheinend auch ganz gut funktioniert. Es läuft aber auch nur dort, wo HTML-Code durch mich beeinflussbar ist.

Seit der Version 1.8 beherrscht Piwik jedoch auch das [Parsen und Einlesen von Apache Logfiles](http://piwik.org/log-analytics/) und das wollte ich dann gestern auch mal ausprobieren.

Nach ein Bisschen rumprobieren ist mir ein Fehler bzw. unerwünschtes Verhalten aufgefallen. Vorher hatten alle Seiten einen eigenen Apache-vHost und entsprechend eigene Logs. Da jetzt alle Blogs unter einem einzigen vHost laufen, waren die Logs nicht mehr aussagefähig, da ja alle Seitenaufrufe an den selben Host gingen.

### Apache beibringen, mehr bzw. anders zu loggen

Die Lösung lag also darin, Apache zu sagen, dass er anders loggen soll.

Hierfür nutze ich in der vHost-Datei unter _/etc/apaches2/sites-avaliable/_ die Definitionen _LogFormat_ und _CustomLog_.

    LogFormat "%{Host}i %h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i"" vhost_common
    CustomLog "|/usr/sbin/rotatelogs /var/www/$DOMAIN/logs/access.%Y-%m-%d.log 86400" vhost_common

Mit _Logformat_ sage ich, in welchem Format die Logs geschrieben werden sollen. Hierbei kommt dann sowas raus, wie z.B:

    skrupuloes.de XXX.XXX.XXX.XXX - - [08/Jan/2013:11x:03:39 +0100] "GET /feed/podcast-mp3/ HTTP/1.1" 200 9964 "-" "PritTorrent/0.1"
    skrupuloes.de XXX.XXX.XXX.XXX - - [08/Jan/2013:11:10:27 +0100] "GET /wp-content/uploads/sites/7/2012/09/coverart-300x274.jpg HTTP/1.1" 304 - "http://skrupuloes.de/ueber-skrupuloes/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"
    skrupuloes.de XXX.XXX.XXX.XXX - - [08/Jan/2013:11:10:27 +0100] "GET /favicon.ico HTTP/1.1" 200 - "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"
    debilux.org XXX.XXX.XXX.XXX - - [08/Jan/2013:11:10:31 +0100] "GET / HTTP/1.1" 200 14279 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"
    debilux.org XXX.XXX.XXX.XXX - - [08/Jan/2013:11:10:33 +0100] "GET /2012/09/28/fuer-filevault-anderes-passwort-nutzen-als-fuer-systemaccount/ HTTP/1.1" 200 13658 "http://debilux.org/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/537.4"

_%{Host}i_ ist hierbei dafür zuständig, dass auch die Domain mitgeloggt wird, über die der Zugriff erfolgte. Jetzt sind die Logs wieder aussagefähig.

Die _CustomLog_-Direktive sagt Apache, wie er die Logs in welche Files schreiben soll. Ich nutze hier _rotatelogs_, um die Files jeden Tag zu rotieren. Meine Logs sind dann zum Beispiel unter _/var/www/$DOMAIN/logs/access.2013–01–07.log_ zu finden.

_$DOMAIN_ steht hier für den Ordner, den ich für jede Domain unter _/var/www/_ habe. Diese beinhalten einen Ordner _“logs/”, in dem die Logs der jeweiligen Domain abgelegt werden. _%Y-%m-%d_ wird Durch Jahr-Monat-Tag ersetzt. Jede Nacht um 0:00 Uhr wird ein neues Log angefangen und die Logs vom Vortag sind “fertig”.

### Apache-Logs in Piwik einlesen

Der Parser für die Piwik-Logfiles liegt im Piwik-Verzeichnis unter _/misc/log-analytics/import_logs.py_. Man kann ihm viele Argumente mit auf den Weg geben und praktischerweise gleich mehrere Logfiles auf einmal zum Fraß vorwerfen. Da ich keine Lust hatte, großartige Configs zu schreiben, haben ich mir ein kleines Shellscript gebastelt.

    #!/bin/bash

    PATH_TO_PIWIK='/var/www/meine_domain/www/piwik' # e.g. /var/www/piwik
    PIWIK_URL='https://meine_domain/piwik' # e.g. http://mysite.tld/piwik
    WWWFOLDER='/var/www/'

    # search logs
    LOGDATE=`(date --date='1 days ago' '+%Y-%m-%d')`
    LOGFILES=`(find $WWWFOLDER -iname access.$LOGDATE.log | grep "/logs/" | tr 'n' ' ')`

    # import found logs to piwik
    python $PATH_TO_PIWIK/misc/log-analytics/import_logs.py --url=$PIWIK_URL --recorders=4 --add-sites-new-hosts --show-progress $LOGFILES

    # run Piwik Auto-Archiving
    php5 $PATH_TO_PIWIK/misc/cron/archive.php --url=$PIWIK_URL

In den ersten drei Variablen sage ich dem Script, wo es Piwik findet, wie Piwik per URL zu erreichen ist und wo die Webseiten, respektive Logs liegen. _$LOGDATE_ stellt fest, welches Datum gestern war (da sind ja die Logs schon “fertig”) und mit Logfiles suche ich dann in _/var/www/_ nach den Logs von gestern und ersetze in der Ausgabe Zeilenumbrüche durch Leerzeichen, damit ich sie an den Importer als Parameter weitergeben kann.

Anschließend lasse ich den Importer laufen. Er nutzt vier Threads und legt noch unbekannte Hosts automatisch in Piwik an (spart wieder Arbeit ;) ). Es gibt noch viele Parameter mehr, aber die könnt ihr Auch ja auch selbst anschauen.

Da es hier auch irgendwie reinpasst, lasse ich mit dem Piwik Auto-Archiving auch gleich noch die [Datenbank aufräumen](http://piwik.org/docs/setup-auto-archiving/).

Das Script läuft bei mir jede Nacht als Cronjob, sodass ich jeden Morgen die Statistiken von gestern einsehen kann. Die sind jetzt zwar nicht mehr tagesaktuell, ich kann aber zum ersten Mal auch die Downloads unseres Podcasts, die nicht über die Seite gingen, tracken.
