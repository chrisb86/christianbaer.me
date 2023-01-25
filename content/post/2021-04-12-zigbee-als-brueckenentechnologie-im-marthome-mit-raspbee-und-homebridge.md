---
date: 2021-04-12 10:19:08+00:00
draft: false
title: "Zigbee als Brückentechnologie im Smarthome mit RaspBee und Homebridge"
slug: "zigbee-als-brueckentechnologie-im-smarthome-mit-raspbee-und-homebridge/"

description: "Raspberry Pi mit RaspBee II-Modul als universelle Zigbee-Bridge in HomeKit."
type: post
tags:
- HomeKit
- SmartHome
- Zigbee
- Homebridge
---
Ich habe in den letzten Monaten damit begonnen, zu Hause ein Bisschen mit Smart-Home-Geräten und HomeKit zu experimentieren.

Auslöser war der Wunsch die Beleuchtung an meinem Schreibtisch ein wenig besser steuern zu können um für "casual Computing", Arbeiten und Videocalls unterschiedliche Beleuchtungssituationen zu haben, die bis zum Tageslichtsprektrum reichen.

Eingezogen sind somit die ersten drei [Philips Hue](https://www.philips-hue.com/de-de)-Birnen, sowie die dazugehörige Hue-Bridge.

Im nächsten Schritt wollte ich das ganze auch über einen physischen Schalter steuerbar machen. Ich habe mir also einen Hue Button und den ["Zauberwürfel" von Aqara](https://www.aqara.com/us/cube.html) zugelegt. Den Hue Button konnte ich erwartungsgemäß ziemlich einfach einbinden. Gehapert hat es dann aber am Aqara-Würfel. Dieser benötigt nämlich die Aqara-Bridge, was mir vorher nicht so klar war.

Da ich keine Lust hatte, mir jetzt auch noch eine Aqara-Bridge ins Haus zu holen, welche wohl auch noch einen Cloud-Zwang mit sich zu bringen scheint, machte ich mich auf die Suche nach Alternativen.

Relativ schnell stieß ich auf den [RaspBee II](https://phoscon.de/de/raspbee) von [dresden elektronik](https://www.dresden-elektronik.de). Dies ist ein kleines  Modul, welches auf den GPIO-Port des Raspberry Pi gesteckt wird und ihm ermöglicht, Zigbee zu sprechen, was das Protokoll ist, dass die meisten Smart-Home-Bridges nutzen, um mit ihren Geräten zu kommunizieren. Die Technik des RaspBee gibt es als ConBee auch noch in Form eines USB-Sticks, der dann auch an "normalen" PCs genutzt werden kann.

Da ich noch einen ungenutzten Raspberry Pi in der Schublade liegen hatte, dachte ich mir, ich probiere das einfach mal aus. Das Modul kostet die Hälfte der Aqara-Bridge und hat sich dann schon quasi gelohnt. Die Hue Bridge kann ich auch wieder abstoßen und mir hoffentlich zukünftig auch den Kauf von weiteren Bridges sparen.

Aber zuerst mal noch ein kleiner und oberflächlicher Ausritt zu Zigbee.

[Zigbee](https://de.wikipedia.org/wiki/ZigBee) ist ein Mesh-Netzwerk. Das bedeutet, alle Zigbee-Geräte untereinander schließen sich zusammen und können (soweit sie dauerhaft am Strom hängen) Signale dorthin weiterleiten, wo sie hin sollen. So kann eine Birne auch sehr weit von der Bridge entfernt sein, wenn zwischendurch noch genug andere Geräte eingebunden sind, die die Wegstrecken verkürzen. Eine strategisch platzierte Zigbee-Steckdose oder Birne im Obergeschoss reichen meist schon aus, um das Erdgeschoss mit dem Dachgeschoss zu verbinden.

Das Problem aktuell ist jedoch, dass die meisten Hersteller ihre eigenen Bridges an den Start bringen und diese jeweils voneinander unabhängige Zigbee-Netzwerke aufbauen. Dann meshed Hue mit Hue, Aqara mit Aqara usw. Und der ganze schöne Vorteil von Zigbee ist dem Vendor-LockIn zum Opfer gefallen.

Mit [Thread](https://www.threadgroup.org) ist eine auf diesen Bausteinen aufbauende Technologie im Anmarsch, die ähnlich funktioniert und Herstellerunabhängigkeit und ein Leben ohne Bridges verspricht. Hier braucht man dann nur noch einen Thread-fähigen Border-Router wie z.B. den HomePod mini und alle Geräte können über ihn meshen. Die Anzahl an Thread-fähigen Geräten wächst langsam und viele Geräte mit Zigbee und Bluetooth sind zumindest hardwareseitig wohl auch schon Thread-fähig.

Bis alles mit Thread realisierbar ist, bleibt Zigbee aber die Brückentechnologie (pun intended).

Nun zurück zum RaspBee II. Das Modul ermöglicht es nun, mit dem Raspberry Pi eine Zigbee-Bridge aufzubauen, die mit Geräten unterschiedlichster Hersteller spricht. Ich habe jetzt zum Beispiel meine Hue-Geräte, sowie den Aqara-Schalterwürfel eingebunden. Ebenso wäre es möglich, Bosch- oder IKEA-Geräte mit einzubinden.

Der Vorteil liegt nun darin, dass ich nur noch eine Bridge habe. Und wie durch ein Wunder sprechen auf ein mal auch alle Geräte miteinander und ich habe ein einziges wunderbar großes Zigbee-Netz.

Um das zu realisieren, gibt es für den RaspBee II die [deCONZ-Software](https://www.dresden-elektronik.de/funk/software/deconz.html). Diese ist quasi die Steuerungsschicht, über die der Raspberry Pi mit den Zigbee-Geräten sprechen kann. Verwaltet wird dies entweder über die Shell, oder über die [Phoscon App](https://www.phoscon.de/de/app/doc). Diese ist ein Webinterface, die es ermöglicht, über den Browser Geräte zu pairen, Firmware-Updates einzuspielen, Räume und Szenen anzulegen und eben alles zu machen, was man mit der Hue Bridge auch machen kann.

Mit einer [Homebridge](https://homebridge.io) und einem [entsprechenden Plugin](https://www.npmjs.com/package/homebridge-hue) lässt sich das ganze auch in Apples HomeKit einbinden und dann alles schön automatisieren und über den Mac, iOS-Geräte oder eben Siri, steuern.

Da die Installationsanleitung mit ein paar Tipps, um das ganze ein Bisschen weniger fehleranfällig zu machen, hier den Rahmen sprengen würde, kommt diese im [nächsten Post](https://christianbaer.me/post/2021/04/raspberry-pi-als-universelle-zigbee-bridge-in-homekit-konfigurieren/).

