---
date: 2023-10-05 22:49:24+00:00
draft: false
title: "Root-less Podman als Docker-Alternative unter Debian"
slug: "root-less-podman-als-docker-alternative-unter-debian/"

description: "Root-less Podman als Docker-Alternative unter Debian"
type: post
tags:
- Debian
- Linux
- Docker
- Podman
- Container
---

Ich habe in den letzten Tagen ein Bisschen mit [podman](https://podman.io/) rumgespielt. podman positioniert sich als drop-in-Alternative zu [Docker](https://www.docker.com/) und ermöglicht es, Container auch als nicht root-User zu nutzen.
Primär für mich habe ich mal aufgeschrieben, wie ich das alles aufgesetzt habe.

Als OS habe ich ein aktuelles Debian genutzt.

## Podman installieren
```sh
sudo apt install podman podman-compose
```

Um container starten zu können, wenn der User nicht eingeloggt ist bzw. die Container weiter laufen zu lassen, wenn der User sich ausloggt, muss _linger_ aktiviert werden.
```sh
sudo loginctl enable-linger ${USER}
```

Falls es möglich sein soll, Container bzw. Dienste auf privilegierten Ports (unter 1024) hören zu lassen (z.B. für einen Samba-Server), können wir das folgendermaßen aktivieren.
```sh
echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee -a /etc/sysctl.d/podman-privileged-ports.conf
sudo sysctl --load /etc/sysctl.d/podman-privileged-ports.conf
```

Damit sind die Grundvoraussetzungen gegeben. Alles Weitere wird als nicht-root User ausgeführt.

## Podman root-less nutzen
Die nötigen Verzeichnisse anlegen:
```sh
mkdir -p ${HOME}/docker
mkdir -p ${HOME}/.config/systemd/user
mkdir -p ${HOME}/.config/containers
```

### docker.io als Container-Registry hinzufügen:
```sh
cp /etc/containers/registries.conf ${HOME}/.config/containers/
echo "
[registries.search]
registries = ['docker.io']" | tee -a ${HOME}/.config/containers/registries.conf
```

## Yacht-Container aufsetzen

[Yacht](https://yacht.sh/) ist ein Verwaltungstool für Docker und bietet auch schon rudimentären Support für podman. Da podman standardmäßig ohne Daemon im Hintergrund arbeitet, müssen wir zunächst einen userspezifischen socket starten. Ebenfalls ist es bei podman deshalb nmotwendig, systemd zum (neu)-starten der Container zu benutzen. Im Folgenden setze ich einen Yacht-Container auf lasse ihn über systemd beim booten starten.

### Podman-socket starten
```sh
systemctl --user enable --now podman.socket
```

Der Socket ist jetzt verfügbar unter _/var/run/user/$(id -u)/podman/podman.sock_.

### Yacht Container starten
```sh
podman volume create yacht
podman run -v /var/run/user/$(id -u)/podman/podman.sock:/var/run/docker.sock -v yacht:/config -p 8000:8000 --name yacht -d ghcr.io/selfhostedpro/yacht:latest
```

### systemd-Service für Yacht erstellen, damit der Container beim Booten gestartet wird
```sh
podman generate systemd --new --name --files yacht
mv container-yacht.service ${HOME}/.config/systemd/user/
systemctl --user enable --now container-yacht.service
```
## docker compose
_docker compose_ kann einfach durch _podman-compose_ ersetzt werden. ein ```podman-compose up -d``` pulled die notwendigen images und startet den Container.

Was ich noch nicht zum Laufen bekommen habe, sind builds aus einem git-Repo über eine docker-compose.yml wie z.B.

```yaml
version: '3'

services:
  cbme:
    image: christianbaer.me
    container_name: christianbaer_me
    build:
      context: https://github.com/chrisb86/christianbaer.me.git
```