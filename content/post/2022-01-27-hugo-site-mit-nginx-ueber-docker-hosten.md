---
date: 2022-01-27 10:34:08+00:00
draft: false
title: "hugo-Site mit nginx über Docker hosten"
slug: "hugo-site-mit-nginx-ueber-docker-hosten/"

description: "Eine hugo Website aus einem git-Repository clonen und die Dateien in ein nginx-Dockerimage kopieren, um sie in einem COntainer zu hosten"
type: post
tags:
- Docker
- hugo
- nginx
- traefik
---

Ich habe in den letzten Monaten viele meiner Services auf Docker migriert, da in einigen Bereichen die Adminsitration wesentlich einfacher und schneller machbar ist, als es mit einem baremetal FreeBSD-System und selbst administrierter Software der Fall wäre.

Meine Webseite betreibe ich, nach wie vor, mit _hugo_. Als reverse Proxy setze ich _traefik_ ein.

Ich stand also vor der Herausforderung, meine Webseite aus den hugo-Sourcen zu rendern und diese dann über einen Webserver zur Verfügung zu stellen, den ich hinter _traefik_ hängen kann. Bisher habe ich das Rendern immer auf meinem MacBook erledigt, und die fertige Seite per rsync in mein nginx-Verzeichnis geschoben.

Da ich diesen Prozess auch vereinfachen wollte, begann ich damit, meine hugo-Quellen jetzt in einem _git-Repository_ zu pflegen.

Da die Dateien jetzt einfach clonebar sind, gestaltet sicher der Prozess des Hostings ziemlich simpel.

Wir brauchen ein _Dockerfile_, sowie eine _docker-compose.yaml_.

Im _Dockerfile_ beschreiben wir, wie das Image gebaut werden soll. In der _docker-compose.yaml_ wird es gebaut, daraus ein Container erstellt und dieser in die restliche Infrastruktur eingebunden.

## Dockerfile

```Dockerfile
FROM alpine as build
RUN apk add --no-cache git hugo

RUN git clone https://github.com/chrisb86/christianbaer.me /site

WORKDIR /site
RUN hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

EXPOSE 8080
```

Im Dockerfile definieren wir, dass wir ein alpine-Image nutzen und in diesem sowohl _git_, als auch _hugo_ installieren.
Anschließend wir das git-Repository mit der hugo-Site nach _/site_ geklont.

Im nächsten Schritte wechseln wir nach _/site_ und lassen hugo die Webseite rendern.

Als letztes nutzen wir ein _nginx-unprivileged_-Image und kopieren die gerenderte Webseite von _/site/public_ in die Webroot unter _/share/nginx_html_ von wo aus sie unter dem Port _8080_ angeboten wird.

Diesen öffnen wir aus dem Image heraus.

Wenn hier eine andere Seite genutzt werden soll, muss nur die URL zum git-Repository geändert werden.


## docker-compose.yaml
```docker-compose
version: '3'

services:
  cbme:
    image: christianbaer.me
    container_name: christianbaer_me
    build:
      context: .
      dockerfile: Dockerfile
    networks:
      - proxy
    labels:
      - traefik.enable=true
      - traefik.http.routers.cbme.rule=Host(`christianbaer.me`)
      - traefik.http.routers.cbme.entrypoints=https
      - traefik.http.routers.cbme.tls.certresolver=inwx
      - traefik.http.routers.cbme.middlewares=secured@file
      - traefik.http.routers.cbme.tls.options=modern@file
      - traefik.http.services.cbme.loadbalancer.server.port=8080
      - traefik.docker.network=proxy

networks:
  proxy:
    external: true

```

In der _docker-compose.yaml_ definieren wir einen Service für unser Image. Über die build-Anweisungen sagen wir _docker-compose_, dass wir das Image aus dem aktuellen Ordner heraus bauen wollen, und welches Dockerfile wir hierfür nutzen. 

Die networks- und label-Parts binden das Image in mein traefik-Netzwerk ein, sorgen dafür, dass es über TLS unter https://christianbaer.me erreichbar ist und kümmern sich um die Zertifikate. Falls ein anderer Proxy genutzt wird, kann der Teil entsprechend weggelassen werden und stattdessen z.B. über _ports: 80:8080_ der Webserver unter POrt 80 erreichbar gemacht werden.

Alles in allem ist das alles viel einfacher, als gedacht. Ich schreibe jetzt einfach einen Beitrag, committe ihn zu git und baue über `docker-compose up -d --build` in ein paar Sekunden das Image neu. Um alles andere kümmert sich Docker.


