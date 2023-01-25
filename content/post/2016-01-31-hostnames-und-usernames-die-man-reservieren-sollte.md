---

date: 2016-01-31 08:57:29+00:00
draft: false
title: Hostnames und Usernames die man reservieren sollte
type: post
aliases:
    -  /782-hostnames-und-usernames-die-man-reservieren-sollte/
Categories: ["Linkschleuder"]

tags:
- dns
- server
- zertifikate
---

Wenn man im Internet Dienste anbietet, die es Menschen ermöglichen, sich selbst zu registrieren, macht es Sinn, von vorneherein einige Namen selbst zu reservieren oder die Reservierung dieser zu blocken.

Bei einigen gibt es Vorschriften, bei anderen Ratschläge aus RFCs und wieder andere sind aus anderen Gründen einfach sinnvoll. Insbesondere, wenn der Username am Ende zu einer automatisch generierten Subdomain oder E-Mail-Adresse führt, kann es hier ganz schnell zu ungewünschten Effekten kommen, die es gilt, zu vermeiden.

Geoffrey Thomas hat in seinem [Blogbeitrag](https://ldpreload.com/blog/names-to-reserve) mal eine [Liste solcher Namen](https://ldpreload.com/files/names-to-reserve.txt) erstellt und will diese weiterpflegen. Er erklärt auch, warum welche Einträge darin aufgenommen wurden.

Aktuell empfiehlt er folgende Namen zu blocken:

    abuse
    admin
    administrator
    autoconfig
    broadcasthost
    ftp
    hostmaster
    imap
    info
    is
    isatap
    it
    localdomain
    localhost
    mail
    mailer-daemon
    marketing
    mis
    news
    nobody
    noc
    noreply
    no-reply
    pop
    pop3
    postmaster
    root
    sales
    security
    smtp
    ssladmin
    ssladministrator
    sslwebmaster
    support
    sysadmin
    usenet
    uucp
    webmaster
    wpad
    www
