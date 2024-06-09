---
title: "ZFS: Making L2ARC Dumb On Purpose"
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

I have a NAS.  
It runs a [ZFS raidz1](https://en.wikipedia.org/wiki/ZFS#RAID_(%22RAID-Z%22)) that's not particularly fast (reads 300~350MB/s max?).  
It's also attached to a 10gb LAN.  
So I thought: wouldn't it be nice if I could just plonk in an SSD cache and saturate that?  

I put in a drive, `zpool add zfs cache/dev/nvme0n1p1`'d[^shortstroke] it, read a bunch of files, saw the cache utilisation line go up in monitoring, got exited, and got *absolutely no improvement in read speeds*.

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:06 [ 324MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:01:34 [ 226MiB/s] [==================================>] 100%
```

The random test file wouldn't go faster even after 10+ full reads.  
Turns out, L2ARC doesn't really do sequential data like that at all by default: 
- Prefetched (sequential) data is [not cached by default](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-noprefetch)
- The [maximum prefetch distance](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#zfetch-max-distance) is 1MB -> not a lot of data gets prefetched anyway
- The fill rate of the L2ARC is [capped at 8MB/s](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-write-max) by default

That *is* actually pretty smart for enterprisey big arrays where the combined sequential speed of a bunch of spinning rust is actually pretty fast and you don't want to waste your pricey cache on that.  

But I really just want a dumb LRU-type cache that makes my steam library go fast.  

Fortunately you can make it kind of behave like that:

```bash
# enable prefetching into L2ARC
echo 0 > /sys/module/zfs/parameters/l2arc_noprefetch
# increase the prefetch distance to 2GB (chosen pretty much arbitrarily, anything really big is good)
echo 2147483648 > /sys/module/zfs/parameters/zfetch_max_distance
# increase L2ARC write cap to 1GB/s (my SSD writes at around that speed)
echo 1073741824 > /sys/module/zfs/parameters/l2arc_write_max
```
And make it persistent:
```bash
echo "options zfs l2arc_noprefetch=0 zfetch_max_distance=2147483648 l2arc_write_max=1073741824" > /etc/modprobe.d/zfs.conf
```

And the result:

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:04 [ 333MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:00:13 [1.44GiB/s] [==================================>] 100%
```
Nice.


[^shortstroke]: I partitioned and [short stroked](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics#Short_stroking) the SSD, so it doesn't just completely fill up and turn into molasses. 
