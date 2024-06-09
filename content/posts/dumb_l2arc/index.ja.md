---
title: "ZFS: L2ARCを素朴化"
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

NASで[ZFSのraidz1](https://en.wikipedia.org/wiki/ZFS#RAID_(%22RAID-Z%22))を使ってるけど、読み取り速度最大300~350MB/sで割と遅い。  
そして10ギガのLANに繋がってる。  
だからSSDのキャッシュ入れてそれを飽和できれば、と。  

SSD入れて、`zpool add zfs cache/dev/nvme0n1p1`[^shortstroke]実行して、ファイル読んだらモニタリングでキャッシュ使用量が上がってるの見たからワクワクしだしたが、*スピード1ミリも速くならなかった*

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:06 [ 324MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:01:34 [ 226MiB/s] [==================================>] 100%
```

テスト用のファイルを10回以上読んでも全然速くならなかった。
結局、L2ARCってデフォルトでシーケンシャルなデータをキャッシュしないことがわかった。
- プリフェッチされた（＝シーケンシャル）データは[キャッシュされない](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-noprefetch)
- [最大プリフェッチ距離](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#zfetch-max-distance)は1MB → そもそもプリフェッチされるデータの量が少ない
- L2ARCに書き込み速度は[8MB/sに制限されている](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#l2arc-write-max)


エンタープライズで使われるハードディスク10台のアレイとかだと、ディスクだけでかなりのスピードが出て、シーケンシャルなデータをキャッシュに入れる必要がないからこれは賢いこと。

だが、僕はSteamライブラリーを速くしてくれる単なる[LRU](https://ja.wikipedia.org/wiki/Least_Recently_Used)的なキャッシュがほしい。

ありがたいことに、設定を弄ればそういうキャッシュにするのも可能：

```bash
# プリフェッチされたデータのキャッシュをON
echo 0 > /sys/module/zfs/parameters/l2arc_noprefetch
# 最大プリフェッチ距離を上げる（いい値よくわからないけど適当高めに）
echo 2147483648 > /sys/module/zfs/parameters/zfetch_max_distance
# 書き込み速度を上げる（SSDそのもの最大1GB/sだから1GB/sにした）
echo 1073741824 > /sys/module/zfs/parameters/l2arc_write_max
```

設定を永続化：
```bash
echo "options zfs l2arc_noprefetch=0 zfetch_max_distance=2147483648 l2arc_write_max=1073741824" > /etc/modprobe.d/zfs.conf
```

すると結果は：

```bash
# pv test.dat >/dev/null
20.0GiB 0:01:04 [ 333MiB/s] [==================================>] 100%
# pv test.dat >/dev/null
20.0GiB 0:00:13 [1.44GiB/s] [==================================>] 100%
```
ナイス。


[^shortstroke]: SSDがいっぱいになって重くならないように、パーティション作って[半分ぐらいだけをL2ARCに割り当てた](https://en.wikipedia.org/wiki/Hard_disk_drive_performance_characteristics#Short_stroking)
