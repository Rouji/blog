---
title: "ZFS: L2ARC Absichtilich Dumm Machen"
date: 2024-04-07T11:25:00Z
draft: false
tags:
  - zfs
  - nas
  - linux
cover:
  image: "cover.png"
  hiddenInSingle: true
---

Ich hab eine NAS. 
Auf der läuft ein [ZFS raidz1](https://de.wikipedia.org/wiki/ZFS_(Dateisystem)#Redundanz), das nicht besonders schnell ist (liest maximal 300~350MB/s?).  
Und sie steckt an einem 10gb LAN.  
Und da dachte ich mir: wäre es nicht schön, könnt ich einfach eine Cache SSD reinfetzen und die Leitung voll bekommen?  

Also hab ich eine SSD reingesteckt, `zpool add zfs cache/dev/nvme0n1p1`[^shortstroke], paar Dateien gelesen, die Cache-Auslastung im Monitoring raufgehen gesehen, mich gefreut, und *absolut keine Verbesserung in der Lesegeschwindigkeit* bekommen.

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:06 [ 324MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:01:34 [ 226MiB/s] [==================================>] 100%
```

Das random Testfile ist nicht schneller geworden, auch nach 10+ vollen Lesedurchgängen.  
Es stellt sich heraus, dass L2ARC standardmäßig sequentielle Daten gar nicht wirklich beschleunigt:  
- Geprefetchte (sequentielle) Daten werden [standardmäßig nicht gecachet](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-noprefetch)
- Die [maximale Prefetch-Distanz](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#zfetch-max-distance) ist 1MB -> wird sowieso recht wenig geprefetcht
- Die Füllrate vom L2ARC ist [standardmäßig auf 8MB/s limitiert](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-write-max)

Und das ist *eigentlich* auch ziemlich schlau so. Große enterprise-ige Arrays haben mit genug Platten insgesamt recht hohe sequentielle Performance, und dann bringt es auch nichts, das teure SSD Cache dafür zu verschwenden.  

Aber ich will eigentlich nur ein relativ dummes LRU-artiges Cache damit meine Steam Library schnell geht.

Glücklicherweise kann man das grob so hinbiegen:

```bash
# prefetching in den L2ARC aktivieren
echo 0 > /sys/module/zfs/parameters/l2arc_noprefetch
# prefetch Distanz auf 2GB erhöhen (ziemlich willkürlich gewählt, aber irgendein großer Wert ist gut)
echo 2147483648 > /sys/module/zfs/parameters/zfetch_max_distance
# L2ARC Schreiblimit auf 1GB/s erhöhen (meine SSD schreibt ungefähr so schnell)
echo 1073741824 > /sys/module/zfs/parameters/l2arc_write_max
```

Und persistent machen:

```bash
echo "options zfs l2arc_noprefetch=0 zfetch_max_distance=2147483648 l2arc_write_max=1073741824" > /etc/modprobe.d/zfs.conf
```

Und das Ergebnis:

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:04 [ 333MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:00:13 [1.44GiB/s] [==================================>] 100%
```
Nice.


[^shortstroke]: Ich hab meine SSD partitioniert und ge[shortstroke](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics#Short_stroking)t, damit sie nicht einfach komplett vollgeschrieben und lahmarschig wird. 
