---

date: 2016-04-19 11:16:04+00:00
draft: false
title: Status einer SSH-Session an sudo weitergeben
type: post
aliases:
    -  /838-status-einer-ssh-session-an-sudo-weitergeben/


tags:
- shell
- ssh
- sudo
---

Wenn man sich per SSH auf einen Rechner connected und anschließend mit ''sudo'' root-Rechte erlangt, kann man in dieser Session nicht feststellen, ob man per SSH verbunden ist, oder nicht. Ich brauchte dies z.B., um meinen Shell-Prompt in diesem Fall anders anzuzeigen.

Es ist aber sehr einfach, hier Abhilfe zu schaffen. Wir müssen sudo nur sagen, dass es die Variablen betreffend SSH im Environment halten soll.

Hierfür müssen wir nur folgende Zeile in die sudo-Config (/usr/local/etc/sudoers oder /etc/sudoers) eintragen:

    Defaults env_keep += "SSH_TTY SSH_CONNECTION SSH_CLIENT"

Von nun an sind die drei Variablen auch in sudo-Sessions verfügbar.
