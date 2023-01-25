---
title: "Mac-Keyboard unter Linux benutzen"
date: 2020-05-12T22:08:35+02:00
draft: false
type: post
tags: ["Linux","Keyboard"]
description: ""
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---

Ich habe häufiger das Problem, dass ich in virtuellen Linux-Maschinen, die ich in
VirtualBox auf macOS ausführe kein vernünftiges Keyboard-Layout habe. Wenn man
dann zum Beispiel ein @ eintippen möchte, passiert einfach nichts. Selbst dann,
wenn man beim Setup ein Macintosh-Layout wählt.

Das Problem lässt sich aber recht leicht beheben, indem wir die XKB-Config
anpassen.

Unter Ubuntu-basierten Distributionen erledigen wir das in der Datei
_/etc/default/keyboard_. Einfach folgende Parameter einfügen, und die Tastatur
funktioniert, wie sie soll.

  ```sh
  XKBMODEL="macintosh"
  XKBLAYOUT="ch"
  XKBVARIANT="de_mac"
  XKBOPTIONS="lv3:alt_switch"
  BACKSPACE="guess"
  ```
