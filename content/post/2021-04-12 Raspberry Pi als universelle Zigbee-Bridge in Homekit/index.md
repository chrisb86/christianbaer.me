---
title: "Raspberry Pi als universelle Zigbee-Bridge in Homekit konfigurieren"
date: 2021-04-12T17:31:20+02:00
draft: false
type: post
tags: ["HomeKit","SmartHome","Zigbee","Apple"]
Categories: ["Allgemein"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---
Wie im [letzten Post](https://christianbaer.me/post/2021/04/zigbee-als-brueckentechnologie-im-smarthome-mit-raspbee-und-homebridge/) beschrieben, habe ich mir aus einem alten Raspberry Pi 3 mit dem [RaspBee II-Modul](https://phoscon.de/de/raspbee) eine universelle Zigbee-Bridge gebaut, die ich über [Homebridge](https://homebridge.io/) und das [entsprechende Plugin](https://www.npmjs.com/package/homebridge-hue) in HomeKit einbinde.

{{< imgproc "homeapp" Resize "700x" >}} Screenshot der macOS Home-App {{< /imgproc >}}

Im Folgenden will ich nun die notwendigen Schritte beschreiben, da sie - zumindest mir -  nicht von Anfang an klar waren. Der Post ist recht lang, die Umsetzung dauert aber nur ca. 15 Minuten.

Sowohl für [Homebridge](https://github.com/homebridge/homebridge-raspbian-image), als auch für [deCONZ](https://phoscon.de/en/raspbee/sdcard) gibt es eigene Distributionen, die ihr jeweiliges Projekt vorkonfiguriert mitbringen. Theoretisch ist es auch möglich, in diesen Systemen das jeweils andere Projekt nach zu installieren. Da ich jeweils verschiedene Dinge in der Umsetzung nicht mochte und gerne weiß, was warum wie funktioniert, habe ich mich dazu entschieden, auf einem frischen [Raspbian Lite](https://www.raspberrypi.org/software/operating-systems/) einfach alles von Hand zu konfigurieren. So habe ich alles unter Kontrolle und kann einfacher Anpassungen vornehmen.

Im folgende gehe ich davon aus, dass wir auf einem jungfräulichen Raspbian Buster Lite arbeiten, welches online ist. Der Hostname, den ich gewählt habe lautet "[homebridge.local"](http://homebridge.local) und ich werde auf Ihn im weiteren Text verweisen. Ersetze ihn an den entsprechenden Stellen durch den Hostnamen oder die IP deines Systems.

{{< imgproc "rpi-raspbee-gpio" Resize "700x" >}} Foto eines RaspBee-Moduls im Raspberry Pi {{< /imgproc >}}

## RaspBee-Modul einbauen
Das Einstecken des Moduls ist recht simpel. Es muss an ganz den Rand der Stiftleiste auf der von den USB-Ports abgewandten Seite eingesteckt werden. dresden elektronik hat hierzu eine [bebilderte Anleitung](https://phoscon.de/de/raspbee/install)  veröffentlicht. 

Falls ein Lüfter genutzt werden soll, der eigentlich ebenfalls an die ersten beiden Pins angeschlossen wird, bietet es sich an, hierfür die Pins 14 und 17 zu nutzen. Der Pin 17 bietet statt 5 V zwar nur 3,3 V und der Lüfter dreht dadurch langsamer, aber er kann wenigstens weiter genutzt werden. Die Pin-Belegung ist [hier](https://www.raspberrypi.org/documentation/usage/gpio/) dokumentiert.

## Zugriffsrechte für serielle Schnittstelle aktivieren
Da in aktuellen Raspbian-Versionen die serielle Schnittstelle nicht ohne Weiteres nutzbar ist, müssen wir zunächst die benötigten Zugriffsrechte setzen.

Dies geschieht über `sudo raspi-config`. Dort wählen wir aus dem Menü **_Interface Options_** &rarr; **_Serial Port_** und beantworten die Frage, ob die Login Shell über die serielle Schnittstelle verfügbar sein soll mit _nein_ und die Frage, ob Hardware am seriellen Port aktiviert werden soll, mit _ja_.

Schneller geht es mit `sudo raspi-config nonint do_serial 1`.

Nach einem Neustart sind die GPIO-Pins aktiviert und das Modul für das Betriebssystem ansprechbar.

## Updaten
Zu allererst bringen wir das Basissystem und die Hardware mal auf den aktuellen Stand.

### Firmware
Je nachdem, wie lange der Raspberry Pi schon in der Schublade lag, macht es Sinn, die aktuellen Firmware-Updates zu installieren.

```shell
sudo rpi-update
```

### Raspbian
Anschließend wird der Pi neu gebootet und wir können anschließend Raspian aktualisieren.

```shell
sudo apt update
sudo apt upgrade
```

### IPv6 für apt deaktivieren
Da ich mit den Pis häufiger mal Probleme in Zusammenhang mit apt und IPv6 hatte, weise ich apt an, künftig nur noch über IPv4 zu connecten.

```shell
echo 'Acquire::ForceIPv4 "true";' | sudo tee -a /etc/apt/apt.conf.d/99disable-ipv6
```

## deCONZ installieren

Wenn alles auf dem aktuellen Stand und das RaspBee-Modul verbaut ist, können wir damit beginnen, deCONZ und die Phoscon App zu installieren.

dresden elektronik betreibt ein eigenes Repository für die ganze Software. Wir werden dieses also einbinden, um die Software installieren zu können

### GPG-Key importieren
Als erstes importieren wir den GPG-Key

```shell
wget -O - http://phoscon.de/apt/deconz.pub.key | sudo apt-key add -
```

### Repository hinzufügen
Als nächsten fügen wir das Repository zu apt hinzu und aktualisieren die Paketquellen.

```shell
echo 'deb http://phoscon.de/apt/deconz $(lsb_release -cs) main' | sudo tee -a /etc/apt/sources.list.d/deconz.list
sudo apt update
```

### deCONZ installieren

Wenn das alles erledigt ist, können wir die Software installieren.

```shell
sudo apt install deconz
```

### Port für deCONZ ändern

Standardmäßig hört die Phoscon App auf den Port 80. Da ich gegebenenfalls noch andere Dienste auf dem Pi betreiben und diese hinter einen nginx-Proxy hängen möchte, ändere ich den Port auf 8080.

Dies erreichen wir, in dem wir den systemd-Aufruf für deCONZ überschreiben. Dies könnten wir entweder direkt im Service-File machen, oder die Möglichkeit von systemd nutzen, einen Override zu konfigurieren.

Ich wähle letztere Variante, da das erstens die elegantere Möglichkeit ist und zweitens auch erhalten bleibt, wenn ein Software-Update das normale Service-File überschreibt.

Mit einem `sudo systemctl edit deconz` öffnen wir einen Editor, welcher die benötigte Verzeichnis-Struktur und die override.conf erstellt.
In diesen Editor fügen wir dann Folgendes ein

```ini
[Service]
ExecStart=/usr/bin/deCONZ -platform minimal --http-port=8080
```

Wenn Du einen andere Port nutzen möchtest, ersetze _8080_ entsprechend durch Deine Wunschkonfiguration.

Über `sudo systemctl daemon-reload` weisen wir den Daemon an, die Konfiguration neu einzulesen.

### deCONZ aktivieren und starten
Wenn das alles erledigt ist, können wir den deCONZ-Dienst aktivieren und starten.

```shell
sudo systemctl enable deconz
sudo systemctl start deconz
```

## Homebridge installieren

### node.js installieren

Homebridge ist eine Node.js-Software, die zur Verwaltung der Plugins auf NPM setzt. Wir beginnen also damit, erst mal das offizielle Node.js-Repository hinzuzufügen und die Paketquellen zu aktualisieren.

```shell
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt update
```

### node.js und benötigte Abhängigkeiten installieren

Nun können wir Node.js installieren. Des Weiteren benötigen wir ein paar Pakete, um die jeweiligen Homebridge-Plugins zu bauen.

```shell
sudo apt install -y nodejs gcc g++ make python net-tools
```

### Homebridge installieren

Jetzt ist das System bereit, um Homebridge, sowie das Webfrontend und das Hue-Plugin zu installieren, welches wir nutzen, um Homebridge mit der deCONZ-Bridge zu verbinden. Dies läuft jetzt alles über NPM.

```shell
sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x homebridge-hue
```

### Homebridge Service einrichten

Homebridge bringt ein kleines Tool mit, welches es auf einfachste Art und Weise ermöglicht, Homebridge als systemd-Service zu konfigurieren und hierfür einen eigenen User anzulegen.

```shell
sudo hb-service install --user homebridge
```

Wenn das erledigt ist, legen wir auch für Homebridge einen Override an. Für eine reibungslose Funktion ist es sinnvoll, Homebridge erst nach deCONZ zu starten. Ansonsten versucht Homebridge, deCONZ zu erreichen, bekommt keine Rückmeldung und die gekoppelten Zigbee-Geräte sind erst nach einem erneuten Neustart von Homebridge verfügbar. Das umgehen wir jetzt einfach.

Wir starten also wieder über `sudo systemctl edit homebridge` den Editor und fügen Folgendes ein

```ini
[Install]
After=syslog.target network-online.target deconz.target
```

Von nun an wird Homebridge erst gestartet, wenn deCONZ gestartet wurde und alles sollte geschmeidig durchlaufen.

Zum Abschluss lassen wir die Service-Files neu einlesen und restarten Homebridge noch mal.

```shell
sudo systemctl daemon-reload
sudo systemctl restart homebridge
```

Homebridge ist jetzt auf dem Port _8581_ erreichbar. Der Defaultaccount heißt _admin_ und das Passwort lautet ebenfalls _admin_. Das sollte später in den Einstellungen geändert werden.

## Homebridge konfigurieren und beide Systeme verheiraten

### Homebridge vorbereiten
Die Konfiguration von Homebridge erfolgt über die Datei _/var/lib/homebridge/config.json_. Diese kann entweder direkt auf der Shell oder eben auch über das Webinterface bearbeitet werden.

Wir Fügen erst ein mal folgenden Code hinzu, um das Hue-Plugin in Betrieb zu nehmen.


```json
  "platforms": [
         {
            "name": "Hue",
            "anyOn": true,
            "effects": true,
            "hosts": [
                "homebridge.local:8080"
            ],
            "lights": true,
            "nativeHomeKitLights": true,
            "nativeHomeKitSensors": true,
            "resource": true,
            "sensors": false,
            "platform": "Hue"
        }
    ]
```

Dies bringt Homebridge bei, zu welcher Bridge sie sich verbinden soll und welche Geräte an HomeKit weitergereicht werden sollen. So betreibe ich die Homebridge als Hue-Bridge-Ersatz und bin bisher zufrieden.

Im nächsten Schritt müssen wir dann nach einen User-Account auf der Bridge erstellen, damit Homebridge sich damit verbinden kann.

### deCONZ unlocken

Als erstes öffnen wir hierfür die Phoscon App unter _[http://homebridge.local:8080](http://homebridge.local:8080)_ und vergeben einen Namen sowie ein Login-Passwort für das Gateway.

Den Dialog zum Hinzufügen von Lampen können wir erst ein mal überspringen.

Wenn wir jetzt in Phoscon eingeloggt sind, klicken wir in der Sidebar auf **Gateway**. Dort haben wir die Möglichkeit, ggf. Die Firmware des Moduls, sowie die Phoscon App zu aktualisieren.

Wir klicken unten auf **Erweitert** und anschließend auf den Button **Authenticate App**.

{{< imgproc "phoscon-unlock" Resize "700x" >}} Screenshot der Phoscon App {{< /imgproc >}}

Dies gibt uns nun 60 Sekunden Zeit, uns durch Homebridge einen API-Zugang erstellen zu lassen.

### Zugangsdaten erstellen und in die Konfiguration einfügen

Wir loggen uns also in Homebridge unter [http://homebridge.local:8581](http://homebridge.local:8581) ein und klicken auf das **&#9211;-Symbol**, um Homebridge neu zu starten.

Im Log auf dem Dashboard können wir nun verfolgen, wie Homebridge die Konfiguration und alle Plugins lädt.

Irgendwann meldet die Software, dass ein neuer User angelegt wurde und wie die Zugangsdaten lauten. 

```log
[4/14/2021, 3:14:40 PM] [Hue] Phoscon-GW: dresden elektronik deCONZ gateway v2.10.4, api v1.16.0
[4/14/2021, 3:14:40 PM] [Hue] Phoscon-GW: created user - please edit config.json and restart homebridge
  "platforms": [
    {
      "platform": "Hue",
      "users": {
        "00212EFFFF06F00E": "5A03564876"
      }
    }
  ]
```

Diesen Codeschnipsel kopieren wir nun in unsere Homebridge-Konfiguration.

Die Komplette Konfiguration könnte nun so aussehen.

```json
{
    "bridge": {
        "name": "Homebridge A7F6",
        "username": "0E:FA:B7:84:A7:F6",
        "port": 51775,
        "pin": "119-28-333"
    },
    "accessories": [],
    "platforms": [
        {
            "name": "Config",
            "port": 8581,
            "platform": "config"
        },
        {
            "name": "Hue",
            "anyOn": true,
            "effects": true,
            "hosts": [
                "homebridge.local:8080"
            ],
            "users": {
                "00212EFFFF06F00E": "5A03564876"
            }
            "lights": true,
            "nativeHomeKitLights": true,
            "nativeHomeKitSensors": true,
            "resource": true,
            "sensors": false,
            "platform": "Hue"
        }
    ]
}
```


### Homebridge in HomeKit einbinden
Das Einbinden der Homebridge in HomeKit könnte einfacher nicht sein. 

Sowohl auf dem Homebridge-Dashboard, als auch im Logfile bietet Homebridge uns einen QR-Code an, den wir, wie bei jedem anderen HomeKit-Gerät, mit der Home-App scannen und so importieren können.

### Das war's schon

Nun können wir damit beginnen allerlei Zigbee-Geräte in Phoscon zu pairen. Gegebenenfalls ist ein Neustart von Homebridge notwendig, damit sie in HomeKit erscheinen.
