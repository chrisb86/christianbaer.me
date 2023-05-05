---
date: 2023-05-05 17:13:08+00:00
draft: false
title: "lokale-verzeichnisse-in-bhyve-vm-mounten"
slug: "lokale-verzeichnisse-in-bhyve-vm-mounten/"

description: "Lokale verzeichnisse eines FreeBSD-Servers in einer bhyve-VM mounten."
type: post
tags:
- Docker
- FreebSD
- Virtualisierung
- bhyve
- virtio-9p
---

Ich versuche mich gerade in der Nutzung von [bhyve](https://wiki.freebsd.org/bhyve) als Virtualisierungslösung unter [FreeBSD](https://www.freebsd.org/), um eine Alternative zu [Proxmox](https://www.proxmox.com/) zu haben.

Unter Proxmox betreibe ich z.B. meinen Docker-Host als virtuelle Maschine mit [Alpine Linux](https://www.alpinelinux.org/). Ein Verzeichnis meines Storage-Servers (eigentlich eine FreeBSD-VM) mounte ich über NFS und erstelle regelmäßig Backups der Docker-Daten darauf. Zur Laufzeit liegen alle Daten in der VM. Dies ist notwendig, da insbesondere Datenbanken nicht (gut) funktionieren, wenn ihre Daten auf einem NFS-Share liegen.

Als ich dabei war, dieses Setup unter FreeBSD mit bhyve nachzubauen, bin ich über eine [wesentlich elegantere und stressfreiere Methode](https://github.com/churchers/vm-bhyve/wiki/Virtual-Disks) gestoßen, um Daten in virtuellen Maschinen verfügbar zu machen.

Unter FreeBSD funktiniert das Bereitstellen von geteilten Verzeichnissen [seit FreebSD 13.0](https://www.freebsd.org/releases/13.0R/relnotes/) über  VirtIO-9p (aka VirtFS). So kann man einfach ein lokales Verzeichnis für eine VM verfügbar machen und dieses dann darin mounten.

Zur Verwaltung meiner VMs nutze ich [vm-bhyve](https://github.com/churchers/vm-bhyve). Zur (sehr einfachen) Installation gibt es viele Anleitungen, weshalb ich jetzt hier nicht darauf eingehen werde.

Ich habe eine VM names _docker01_. Diese stoppe ich erst mal mit ```sudo vm stop docker```.

Über ```sudo vm config docker```öffne ich nun die Konfigurationsdatei für die VM.

```sh
loader="grub"
cpu=4
memory="4096M"
network0_type="virtio-net"
network0_switch="dmz"
disk0_type="virtio-blk"
disk0_name="disk0.img"
grub_install0="linux /boot/vmlinuz-virt initrd=/boot/initramfs-virt alpine_dev=cdrom:iso9660 modules=loop,squashfs,sd-mod,usb-storage,sr-mod"
grub_install1="initrd /boot/initramfs-virt"
grub_run0="linux /boot/vmlinuz-virt root=/dev/vda3 modules=ext4"
grub_run1="initrd /boot/initramfs-virt"
uuid="5c93bf9d-eb53-11ed-b2ae-ac1f6b6337b0"
network0_mac="58:9c:fc:0f:c7:5b"
```

Mit folgenden Optionen kann man nun einen 9p-Share hinzufügen:

```sh
disk1_type="virtio-9p"
disk1_name="sharename=/path/to/share" 
disk1_dev="custom"
```

_sharename_ (als Wort) muss nun durch einen Namen ersetzt werden, welchen wir in der VM ansprechen wollen. Der Pfad dahinter, dann entsprechend durch das Verzeichnis, welches wir teilen wollen.

In meinem Fall füge ich also Folgendes ein:

```sh
disk1_type="virtio-9p"
disk1_name="docker=/mnt/dozer/docker-backup"
disk1_dev="custom"
```
Wenn weitere Shares hinzugefügt werden sollen, muss die Disk-Nummer entsprechend erhöht werden (disk2_type usw...).

Wenn die Datei gespeichert ist, können wir über ein ```sudo vm start docker```die VM wieder hochfahren.

In der VM erstellen wir ein Verzeichnis zum Mounten des Shares z.B. mit ```mkdir -p /mnt/docker``` und können dann anschließend über ```mount -t 9p -o trans=virtio docker /mnt/docker``` den Share einbinden.

Wenn alles soweit geklappt hat und die Daten da sind, können wir ```docker /mnt/docker 9p trans=virtio,rw 0 0``` in die _/etc/fstab_ einfügen, um das Verzeichnis zukünftig direkt beim Booten zu starten.

Das alles ist auf jeden Fall schon malö wesentlich einfacher, als alles über NFS zu machen und sich über Firewallregeln, Berechtigungen usw. Gedanken zu machen. Ob ich darauf jetzt Datenbanken betreiben kann, oder nur NFS aus meinem vorherigen Setup ersetzen kann, muss ich noch ausprobieren.

Ich bin auf jeden Fall froh, dass FreeBSD jetzt für mich nicht nur durch Jails, sondern auch mit virtuellen Maschinen nutzbar ist. Für mich ist und bleibt FreeBSD auf dem Server das Betriebssystem der Wahl.
