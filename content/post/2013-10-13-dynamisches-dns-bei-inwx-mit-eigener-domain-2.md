---

date: 2013-10-13 20:29:55+00:00
draft: false
title: Dynamisches DNS bei INWX mit eigener Domain
type: post
aliases:
    -  /656-dynamisches-dns-bei-inwx-mit-eigener-domain-2/


tags:
- dns
- dyndns
- freebsd
- internetworx
- inwx
- nameserver
- script
- shell
---

Ich verwalte alle meine Domains bei [InterNetWorX](https://www.inwx.de) (welcher nebenbei erwähnt, ein ziemlich schnieker Domain-Registrar ist, den ich uneingeschränkt empfehlen kann).

Dieser bietet unter anderem eine API an, mit der ich Domaineinstellungen ändern kann. Da ich meinen Homeserver gerne von außen erreichen möchte, lag die Idee nahe, beides zu kombinieren.

Mit folgendem Script, welches ich auf [Github](https://github.com/chrisb86/nsupdate) gestellt habe, ist es mir möglich, die Nameservereinstellungen automatisch so anzupassen, so dass zum Beispiel _http://homeserver.meinedomain.de_ immer auf meinen Server im heimischen Arbeitszimmer zeigt. So bin ich unabhängig von anderen Diensten und kann ihn eben auch mit meiner eigenen Domain nutzen. Nebenbei kostet mich das alles nichts extra, da die Funktion eben bei INWX eingebaut ist.

Das Script _nsupdate.sh_ wird auf dem Server zu Hause stündlich per cron aufgerufen. Es liest dann die WAN-IP des Anschlusses aus und vergleicht sie mit der IP, die im Nameserver für die Subdomain hinterlegt ist. Wenn sich beide unterscheiden, trägt sie die aktuelle IP per XML-Voodo in den Nameserver ein.

    #!/bin/bash

    # Update a nameserver entry at inwx with the current WAN IP (DynDNS)

    # Copyright 2013 Christian Busch
    # http://github.com/chrisb86/

    # Permission is hereby granted, free of charge, to any person obtaining
    # a copy of this software and associated documentation files (the
    # "Software"), to deal in the Software without restriction, including
    # without limitation the rights to use, copy, modify, merge, publish,
    # distribute, sublicense, and/or sell copies of the Software, and to
    # permit persons to whom the Software is furnished to do so, subject to
    # the following conditions:

    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.

    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    # from which site should we get your wan ip?
    IP_CHECK_SITE=http://checkip.dyndns.org

    source nsupdate.config

    LOG=$0.log

    NSLOOKUP=$(nslookup -sil $HOSTNAME - ns.inwx.de | tail -2 | head -1 | cut -d' ' -f2)
    WAN_IP=`curl -s ${IP_CHECK_SITE}| grep -Eo '<[[:digit:]]{1,3}(.[[:digit:]]{1,3}){3}>'`

    API_XML="nameserver.updateRecord

                      user

                         $INWX_USER

                      pass

                         $INWX_PASS

                      id

                         $INWX_DOMAIN_ID

                      content

                         $WAN_IP

    "

    if [ ! "$NSLOOKUP" == "$WAN_IP" ]; then
        curl -silent -v -XPOST -H"Content-Type: application/xml" -d "$API_XML" https://api.domrobot.com/xmlrpc/
        echo "$(date) - $HOSTNAME updated. Old IP: "$NSLOOKUP "New IP: "$WAN_IP >> $LOG
    else
        echo "$(date) - No update needed for $HOSTNAME. Current IP: "$NSLOOKUP >> $LOG
    fi

Konfiguriert wird das ganze in der _nsupdate.config_. Diese liegt im selber Folder, wie das Script selbst. Hier werden die Zugangsdaten für INWX angegeben. Außerdem steht hier die Subdomain, die wir für DynDNS nutzen wollen und die ID, unter welcher die Domain bei INWX geführt wird.

    # nsupdate.config

    # Login credentials for the inwx admin interface
    INWX_USER="USERNAME"
    INWX_PASS="PASSWORD"

    # The hostname that you want to update and it's ID from the inwx interface
    # You get the ID when you edit the given nameserver entry and hover the save button.
    HOSTNAME="subdomain.example.com"
    INWX_DOMAIN_ID="123456789"

Diese Lösung läuft bei mir jetzt seit einigen Monaten sehr zuverlässig. Die Aktuelle Version findest Du immer auf [meiner Github-Seite](https://github.com/chrisb86/). Getestet habe ich es nur auf dem Mac und FreeBSD.
