---
title: "自作キーボード「Charybdis Nano」作ってみた"
date: 2023-08-20T17:06:00Z
draft: false
tags:
  - keyboard
  - build
cover:
  image: "cover.jpg"
---

カリブディス？  
チャリブヂス？  
ケライブディス？  
…  
[カリュブディス](https://ja.wikipedia.org/wiki/%E3%82%AB%E3%83%AA%E3%83%A5%E3%83%96%E3%83%87%E3%82%A3%E3%82%B9)だった

# 部品
- [Charybdis Nano Kit](https://bastardkb.com/product/charybdis-nano-kit/), RGBとトラックボール付き、ケースなし
- [JLCPCB](https://jlcpcb.com/)の3201PA-F Nylon (SLS)っていう材料で印刷してもらったケース。そのためのSTLファイルはGitHubの[ここ](https://github.com/Bastardkb/Charybdis/tree/main/files/3x5%20nano)と[ここ](https://github.com/Bastardkb/Skeletyl/tree/main/V4)から
- [Gateronのキースイッチ](https://www.gateron.co/products/gateron-g-pro-2-0-switch-set?_pos=3&_sid=c316e5d73&_ss=r)1本
- やすっぽい[XDAプロファイルの「プリン」キーキャップ](https://www.amazon.co.jp/gp/product/B0BN5P62ML/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&th=1)

# 組み立て
はんだ付け的にはほとんど大したことないけど、キットのリボンケーブルがかなり固いから見た目異性植物になったり、ちょっと曲技的な付け方が必要になったりはする。
![weird tree](weird_tree.jpg)
([ハンズフリーツール](https://duckduckgo.com/?q=%E3%81%AF%E3%82%93%E3%81%A0%E4%BB%98%E3%81%91%E3%80%80%E3%83%8F%E3%83%B3%E3%82%BA%E3%83%95%E3%83%AA%E3%83%BC%E3%83%84%E3%83%BC%E3%83%AB&t=ffab&iar=images&iax=images&ia=images)の使用がおすすめ。

## 難しいところ１：スイッチのはんだ付け
スイッチは基板をケースの内側に押し付けて曲げながら付けなければいけない。  
基板はそのための平均より薄いもので、確かに無事に曲がるけど、結局フレックス基板とか特別なものじゃなくてただの[FR4](https://ja.wikipedia.org/wiki/FR4)だからかなりの力を加える必要があって折れちゃいそうな感覚もする。折れないけど。  
あと僕の場合はその固さのせいでケースと基板の間に数ミリの隙間ができた。  

光が漏れるのは残念だけどキーボードの操作の問題にはならない。
![gap](gap2.jpg)

## 難しいところ２：ケーブル
ケーブルが幅広くて割と固いものでケースが狭いせいで、折ったりマイコンの足とかで怪我したりせずに全部入れるのはちょっとだけ面倒なこと。  
僕のはそうはならなかったけどケーブルが何かに接触しただけでゴーストキーが出まくったから足を全部切るのもとても大事みたいだ。
![stuffing](stuffing.jpg)
![stuffing2](stuffing2.jpg)

# QMK
ファームウェアは定番の[QMK](https://qmk.fm/)。 
僕のキーマップを[どうぞ](https://github.com/Rouji/Charybdis-QMK)。  
こんなキーの少ないキーボードの使い方とかはまだよくわかっていないし極めて個人的なものなのでマップそのもののコピペはおすすめできないけど、参考になる部分もあると思う。

## 自動マウスレイヤー
トラックボールを動かすと自動的にレイヤーを切り替えてくれる[auto_mouse_layer](https://github.com/qmk/qmk_firmware/blob/master/docs/feature_pointing_device.md#automatic-mouse-layer-idpointing-device-auto-mouse)。
手動で切り替える必要がなくなってとても快適だけど、カリュブディスの場合は問題が一つ、センサーの感度。
感度が高いのはいいことだけど、高すぎて軽く打っててもその微小な振動まで検出しちゃってトラックボール触らなくても打つだけでレイヤを切り替えてしまう。

以下は閾値でそれを防ぐためのコード。
```C
static const uint16_t AUTO_MOUSE_THRESHOLD = 200;
static uint16_t auto_mouse_cum = 0;

#define ABS(n) ((n) < 0 ? -(n) : (n))
bool auto_mouse_activation(report_mouse_t mouse_report)
{
    auto_mouse_cum += ABS(mouse_report.x) + ABS(mouse_report.y) + ABS(mouse_report.h) + ABS(mouse_report.v);
    if (auto_mouse_cum > AUTO_MOUSE_THRESHOLD)
    {
        auto_mouse_cum = 0;
        return true;
    }
    return false;
}
```
マウスの動きには変化なし。

## トラックボールでスクロール
トラックボールでスクロールするのは意外と素晴らしいことだ。操作的にはノートパソコンのタッチパッドに似てるけどより低遅延で精密だからスクロールするのがすごく気持ちいい。

QMKの[Drag Scroll](https://github.com/qmk/qmk_firmware/blob/master/docs/feature_pointing_device.md#drag-scroll-or-mouse-scroll)っていう機能で簡単に設定できる。 
設定するのが簡単でなんのOSにも対応するけど、普通のマウスのホィールみたいな、一気に数列を飛ぶ全然スムーズじゃない働きになるからあまり好きじゃない。  
スムーズにスクロールできるhigh-res scrolling、「高分解スクロール」っていう機能は未だに[イシュー](https://github.com/qmk/qmk_firmware/issues/17585)となってる。

Linuxではlibinputの[on-button scrolling feature](https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html#button-scrolling) という機能は使ってるマウスに関わらずhigh-res scrollingに対応なので、それでもちゃんとスムーズにスクロールができる。
使い心地全然違うから可能なら是非使ってみてください。

 個人的には、キーマップにKC_MS_BTN4（ブラウザとかで「戻る」ボタン）が入ってて、それをlibinputのスクロールボタンに設定している。

Swayの設定では以下のようなもの  
```
input "43256:6194:Bastard_Keyboards_Charybdis_Nano_(3x5)_Splinky_Mouse" {
    natural_scroll enabled
    scroll_button 275
    scroll_method on_button_down
    scroll_factor 0.3
}
```
ボタンのIDは、`libinput debug-events`が教えてくれる。


# モーツァルトさんは収まらない
[Mozartkugel](https://en.wikipedia.org/wiki/Mozartkugel)は小さすぎてボールになってくれない
![mozart](mozart.jpg)
残念！
