---
date: 2023-06-10 10:12:24+00:00
draft: false
title: "Home Assistant: Benutzer-Authentication mit Authelia und LDAP"
slug: "homeassistant-authentication-mit-authelia/"

description: "Home Assistant: Benutzer-Authentication mit Authelia und LDAP"
type: post
tags:
- Home Assistant
- Authelia
- LDAP
- LLDAP
- Authentication
- SSO
- Single Sign On
---

Ich setze be mir zu Hause zur Authentifizierung und als Lösung für SSO (Single Sign On) [Authelia](https://authelia.com) ein. Als Backend zur Verwaltung der User kommt dabei [LLDAP](https://github.com/lldap/lldap) als abgespeckter LDAP-Server zum Einsatz.

Ich versuche, möglichst alle Dienste, die ich selbst betreibe damit zu Verknüpfen, damit ich nicht an 1000 Stellen viele verschiedene Accounts habe, sondern eben nur eine Instanz, die sich sowohl um Authentifizierung, als auch Berechtigungen kümmert.

Wo immer es geht, versuche ich Authelia einzubinden. Bei Dingen, wo dies mangels (befähigtem) Webfrontend nicht klappt, kommt dann eben LDAP zum Einsatz (z.B. bei E-Mail).

Um das Thema Home Assistant habe ich mich hierbei lane gedrückt. Es war zwar möglich, Home Assistant per OAuth mit Authelia zu verheiraten, das spielte aber bei Nutzung der mobile App nicht richtig zusammen. Die genauen Symptome weiß ich jetzt schon gar nicht mehr.

Die Nutzung von Authentifizierung per LDAP war auch irgendwie hacky, da man erst ein mal die LDAP-Tools in Home Assistant reinbekommen muss, um mit dem Server sprechen zu können. Das war also auch nichts, was mich irgendwie weiter brachte.

Vor ein paar Wochen bin ich dan über den Post [Home Assistant Command Line Authentication for Authelia](https://kevo.io/posts/2023-01-29-authelia-home-assistant-auth/) von Kevin O'Connor gestoßen. Er nutzt einfach die Authelia-API selbst, um die User zu authentifizieren. Hierfür ist nur _curl_ notwendig und das ist bei Home Assistant dabei.

Seine Lösung scherte sich nicht um Gruppen-Berechtigungen, weshalb ich auf seiner Grundlage ein wenig weiter gebaut habe.

Unter [homeassistant-auth-authelia](https://github.com/chrisb86/homeassistant-auth-authelia/) findest Du jetzt ein Script, welches genau das tut. Es erwartet beim Aufruf die Authelia-, und Home Assistant-URLs, sowie optional eine Gruppe, die Berechtigt sein soll, Home Assistant zu nutzen. Der eingegebene Username und das Passwort für von Home Assistant als Umgegungsvariable gesetzt und das Script kann darauf zugreifen.

In die _configuration.yaml_ tragen wir nun einfach folgendes ein:

```yaml
homeassistant:
  auth_providers:
    - type: command_line
      command: /config/bin/auth_authelia.sh
      args:
        ["https://auth.example.com", "https://homeassistant.example.com", "homeassistant_users"]
      meta: true
    - type: homeassistant
```

Das erste Argument ist die Authelia-URL, das zweite Argument ist die Home Assistant-URL und das dritte Argument ist die Gruppe, die Zugriff auf Home Assistant haben soll. Wird die Gruppe weggelassen, schaut das Script eben nur auf Username und Passwort.

Wenn das Script nach _/config/bin/auth_authelia.sh_ kopiert wurde, kann Home Assistant neu gestartet werden und alles sollte laufen.

Single Sign On habe ich mit dieser Lösung zwar noch nicht, ich nutze aber ohne zusätzliche Abhängigkeiten in Home Assistant letztendlich meinen LDAP-Server als Authentifizierungs-Backend und kann den Zugriff auf eine bestimmte Gruppe einschränken.