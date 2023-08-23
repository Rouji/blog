---
title: "Charybdis Nano Keyboard Build"
date: 2023-08-20T17:06:00Z
draft: false
tags:
  - keyboard
  - build
---

![cover](cover.jpg)

# Teile
- [Charybdis Nano Kit](https://bastardkb.com/product/charybdis-nano-kit/), mit RGB und Trackball, ohne Case
- Case 3D-gedruckt von [JLCPCB](https://jlcpcb.com/) mit 3201PA-F Nylon (SLS). STLs gibt's [auf github](https://github.com/Bastardkb/Charybdis/tree/main/files/3x5%20nano) und [auf github](https://github.com/Bastardkb/Skeletyl/tree/main/V4)
- Eine Stange [Gaterons](https://www.gateron.co/products/gateron-g-pro-2-0-switch-set?_pos=3&_sid=c316e5d73&_ss=r)
- Cheapo [XDA "Pudding" Keycaps](https://www.amazon.co.jp/gp/product/B0BN5P62ML/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&th=1)

# Das Ding Zusammenbauen
Großteils nicht super schwierig. Weil die Flachbandkabel im Kit sind steif sind, muss man zwischendurch sehr akrobatische schwebende Lötmanöver an seltsamen Alienbäumen ausführen.  
![weird tree](weird_tree.jpg)
... außer man hat eine dritte Hand. ([das Werkzeug](https://duckduckgo.com/?t=ffab&q=soldering+helping+hands&iax=images&ia=images), oder menschlich)  

## Problematischer Teil #1: Die Switches Anlöten
Man muss die PCBs zurechtbiegen während man die Switches anlötet.  
Die PCBs sind extra-dünn damit das möglich ist.  
Sie sind allerdings keine echten flex PCBs, und fühlen sich and als würden sie dabei durchbrechen.  
Meine sind nicht durchgebrochen, aber haben sich auch nicht richtig biegen lassen und sind auch nach dem Löten nicht komplett gebogen geblieben.  

Die mittlere Reihe war überall problemlos, aber die obere und untere Reihe haben sich geweigert genau zu passen, und haben einen V-förmigen Spalt zwischen PCB und Switch.  
Das hindert die Funktionalität von den Switches und RGB nicht, aber irgendwas ist da definitv nicht ganz richtig. 
![gap](gap2.jpg)

## Problematischer Teil #2: Kabel
Die Kabel sind breit und steif, und viel Platz hat man auch nicht. Die alle stecken wo sie hingehören, und ins Case stopfen ohne dass irgendwas bricht oder durchstochen wird, ist eine ziemliche Arbeit.  
Ich hatte seltsame ghosting Probleme weil ein Pin von einem (eventuell mehrere?) Switch eines von den Kabeln berührt hat, sogar ganz ohne Durchstechen. Es ist auf jeden Fall wichtig, alle Pins zu kürzen und die Kabel möglichst von allen Kontakten wegzubiegen. 
![stuffing](stuffing.jpg)
![stuffing2](stuffing2.jpg)

# QMK
Auf dem Keyboard läuft [QMK](https://qmk.fm/), weil was sonst. Meine Keymap/Config gibt's [hier](https://github.com/Rouji/Charybdis-QMK). 
Ich hab absolut keinen Plan, wie eine effiziente Keymap für so wenige Tasten aussieht. Keine Gewehr auf blinden Copypaste. Die interessanten Teile sind wahrscheinlich alles außer der eigentlichen Keymap.

## Auto Mouse Layer
Der [auto_mouse_layer](https://github.com/qmk/qmk_firmware/blob/master/docs/feature_pointing_device.md#automatic-mouse-layer-idpointing-device-auto-mouse) (ein Layer, der autmatisch aktiviert wird, wenn man den Trackball bewegt) ist super praktisch, aber etwas problematisch mit dem Charybdis.
Der optische Sensor ist sehr *sehr* **sehr** genau und empfindlich. Der nimmt die kleinsten Vibrationen vom sanftesten tippen auf und aktiviert den Layer einfach *permanent*.  

Man kann das fixen mit einem Threshold:  
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
Mausbewegungen sind davon nicht betroffen. Ausschließlich die Layeraktivierung. 

## Mit dem Trackball Scrollen ("Drag Scroll")
Trackballs sind ausgezeichnete Scrollgeräte. Wie 2-Finger-Scrollen auf einem Touchpad, nur genauer, mit weniger Latenz und allgemein angenehmer.  

Das geht komplett in Firmware mit QMK, siehe die [QMK Doku](https://github.com/qmk/qmk_firmware/blob/master/docs/feature_pointing_device.md#drag-scroll-or-mouse-scroll). 
Die Variante funktioniert auf jedem PC, jedem OS, wie eine normale Maus.  
Verhält sich aber wie ein Scrollrad, d.h. es schickt sehr diskrete "scroll 1 Zeile" Events, wie die Ticks von einem Mausrad. Aber weil der Trackball keine diskreten Schritte hat, fühlt sich das sehr seltsam an. High-res Scrolling ist [eine offene Issue](https://github.com/qmk/qmk_firmware/issues/17585). 

Linux-Benutzer können das problem mit libinput umgehen, mit dem [on-button scrolling Feature](https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html#button-scrolling). Das *kann* high-res Scrolling und fühlt sich *deutlich* besser an.
Muss allerdings auf jedem PC konfiguriert werden, den man verwendet.  
Ich habe persönlich KC_MS_BTN4 (den 4ten Mausbutton, aka "zurück-Knopf") in meiner Keymap, und lass libinput den als Scroll-Button verwenden.  

Sway lässt einen dieses libinput feature konfigurieren, und meine Config sieht so aus:  
```
input "43256:6194:Bastard_Keyboards_Charybdis_Nano_(3x5)_Splinky_Mouse" {
    natural_scroll enabled
    scroll_button 275
    scroll_method on_button_down
    scroll_factor 0.3
}
```
Um rauszufinden, welche ID ein Knopf hat, kann man `libinput debug-events` verwenden.

## Kompilieren/Flashen
Wenn man den Resetknopf 2x schnell drückt, meldet sich der Splinky as USB Storage Gerät, auf das man sein .uf2 Firmware File kopieren muss.  
Bisschen komische herangehensweise, aber ganz nett für Kompatiblität/Cross-platform-heit, weil man so keine extra Software zum Flashen braucht. Aber nervig zu automatisieren.  
Ich mach sowas in der Richtung:
```bash
cd $HOME/qmk_firmware
./util/docker_build.sh bastardkb/charybdis/3x5/v2/splinky_3:rj || exit 1
while ! grep -q -s "/run/media/$USER/RPI-RP2" /proc/mounts; do
    sleep 1;
done
echo flashing
cp ./bastardkb_charybdis_3x5_v2_splinky_3_rj.uf2 /run/media/$USER/RPI-RP2
```
Der Splinky resettet sich automatisch, wenn er mit dem Flashen fertig ist. 

# Mozart Passt Ned
[Mozartkugeln](https://en.wikipedia.org/wiki/Mozartkugel) ham an 30mm Durchmesser, ned die 34mm, die i brauch. 
![mozart](mozart.jpg)
Schas.
