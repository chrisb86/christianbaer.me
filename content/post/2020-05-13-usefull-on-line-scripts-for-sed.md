---
title: "Usefull one line scripts for sed"
date: 2020-05-13T09:46:19+02:00
draft: false
type: post
tags: ["shell","sed"]
Categories: ["Linkschleuder"]
description: "Nützliche Onliner für sed"
## Bilder Shortcode
## {{< imgproc Dateiname Resize "700x" >}} Beschreibung {{< /imgproc >}}
## {{< imgproc photo Resize "700x" />}}
---
[Eric Pement](http://www.pement.org/) pflegt  [eine Liste](http://www.pement.org/sed/sed1line.txt)
mit nützlichen Onelinern für sed. Wenn man also mal schauen möchte, was sed alles
kann oder Tipps für einen konkreten Anwendungsfall braucht,lohnt sich ein Blick.
Auch, wenn die letzte Aktualisierung vom 29. Dezember 2005 ist.

Ein Beispiel:

```sh
  # align all text flush right on a 79-column width
  sed -e :a -e 's/^.\{1,78\}$/ &/;ta'  # set at 78 plus 1 space
  ```

