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

Ich habe in den letzten Monaten viele meiner Services auf Docker migriert, da in einigen Bereichen die Administration wesentlich einfacher und schneller machbar ist, als es mit einem baremetal FreeBSD-System und selbst administrierter Software der Fall wäre.

Meine Webseite betreibe ich, nach wie vor, mit _Hugo_. Als reverse Proxy setze ich _traefik_ ein.

Ich stand also vor der Herausforderung, meine Webseite aus den Hugo-Sourcen zu rendern und diese dann über einen Webserver zur Verfügung zu stellen, den ich hinter _traefik_ hängen kann. Bisher habe ich das Rendern immer auf meinem MacBook erledigt, und die fertige Seite per rsync in mein nginx-Verzeichnis geschoben.

Da ich diesen Prozess auch vereinfachen wollte, begann ich damit, meine Hugo-Quellen jetzt in einem _git-Repository_ zu pflegen.

Da die Dateien jetzt einfach clonebar sind, gestaltet sicher der Prozess des Hostings ziemlich simpel.

Wir brauchen ein _Dockerfile_, sowie eine _docker-compose.yaml_.

Im _Dockerfile_ beschreiben wir, wie das Image gebaut werden soll. In der _docker-compose.yaml_ wird es gebaut, daraus ein Container erstellt und dieser in die restliche Infrastruktur eingebunden.

## Dockerfile

```Dockerfile
FROM alpine as build

## Set some variables
ARG HUGO_VERSION=0.110.0
ARG GITHUB_USER=chrisb86
ARG GITHUB_REPOSITORY=christianbaer.me

## Download Hugo from github
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz

## Install git for gitInfo support in Hugo 
RUN apk add --no-cache git

## Copy site sources to /site
COPY ./ /site
WORKDIR /site

# Cache Bust upon new commits
ADD https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPOSITORY}/git/refs/heads/master /.git-hashref

## Run Hugo
RUN /hugo --gc --enableGitInfo

## Copy rendered site to nginx image
FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

## Expose port 8080 to docker
EXPOSE 8080
```

Im Dockerfile definieren wir, dass wir ein alpine-Image nutzen und setzen die zu nutzende Hugo-Version sowie GitHub-User und -Repository.

Anschließend laden wir die spezifizierte Hugo-Version von GitHub herunter und entpacken sie. Um die _--gitInfo_-Option in Hugo nutzen zu können, installieren wir noch _git_ über die Paketverwaltung.

Die Vorbereitungen sind soweit erst mal abgeschlossen.

Damit Docker nicht die ggf. Schon gecachten Site-Quellen nutzt, sondern die aktuellsten, fügen wir dem Image über `ADD`noch eine Datei von GitHub hinzu, die sich bei einem neuen Commit auf jeden Fall geändert hat.

Im nächsten Schritte lassen wir _Hugo_ die Webseite rendern.

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
      context: https://github.com/chrisb86/christianbaer.me.git
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

In der _docker-compose.yaml_ definieren wir einen Service für unser Image. Über die build-context sagen wir _docker-compose_, welches git-Repository als Grundlage für den Container dienen soll. Das darin befindliche _Dockerfile_ wird dann automatisch ausgeführt.

Die networks- und label-Parts binden das Image in mein traefik-Netzwerk ein, sorgen dafür, dass es über TLS unter https://christianbaer.me erreichbar ist und kümmern sich um die Zertifikate. Falls ein anderer Proxy genutzt wird, kann der Teil entsprechend weggelassen werden und stattdessen z.B. über _ports: 80:8080_ der Webserver unter POrt 80 erreichbar gemacht werden.

Alles in allem ist das alles viel einfacher, als gedacht. Ich schreibe jetzt einfach einen Beitrag, committe ihn zu git und baue über `docker-compose up -d --build` in ein paar Sekunden das Image neu. Um alles andere kümmert sich Docker.


