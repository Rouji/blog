---
title: "Minifi: Die Noch Flachere Tastatur"
date: 2025-04-26T12:00:00Z
draft: false
tags:
  - build
  - keyboard
  - 3D Printing
cover:
  image: "keyboard_finished.jpg"
---

Ich hab eine ["Choc"](https://www.kailhswitch.com/info/kailh-choc-switch-41232795.html) basierte, low-profile Tastatur namens [Chocofi](https://github.com/pashutk/chocofi), und mag sie sehr gerne.  

Irgendwann hab ich dann gesehen, dass es *noch flachere* "Choc Mini" Switches gibt, hab mich entschlossen, dass ich die in eine Chocofi reinstopfen will, und bin dann auf diesem Projekt hier sitzen geblieben. 

# Die Choc Mini
![Choc VS Choc Mini Größenvergleich](choc_vs_mini_height.jpg)
Die normalen Chocs sind schon low profile (für mechanische Tastaturen-Verhältnisse), aber die Minis haben ein paar extra Tricks um Höhe zu sparen:
- Anschlag ist um 0.6mm kürzer
- Die Plastikteile, die durchs PCB schauen, sind um 1.5mm kürzer
- Der *Körper vom Switch steckt im PCB drin*

|        | Gesamt | Anschlag | durchs PCB getsteckte Teile|
|--------|-------|--------|-----|
| Choc   | 12mm | 3mm    | 3.3mm |
| Mini   | 8.2mm | 2.4mm | 2.4mm |


Insgesamt 3.8mm Ersparnisse. Klingt nicht besonders viel, aber wenn der Ausgangspunkt 12mm ist, sind das immerhin fast 32%!  
Und *den Switch einfach so durchs PCB stecken* ist irgendwie einfach cool.  


# PCB Umgebauerung
![KiCAD screenshot](kicad_whole.png)
Weil man bei den Choc Minis einen großen Teil vom Switch durch das PCB stecken muss, und sie ganz andere Pins haben, hab ich am PCB ein paar Sachen neu machen müssen.  

Es gab ein paar Footprints für Choc Minis in irgendeiner Library, aber keine reversiblen. Einen Bestehenden hernehmen, spiegeln und verdrahten war aber auch nicht super schwierig. 
Aber dann haben die riesigen neuen Löcher und andere Pin-Platzierung gar nicht mehr mit den Leiterbahnen zusammengepasst und ich hab die ganze Matrix neu geroutet.  
Unerwartet entspannendes Mahlen nach Zahlen.  

## Dioden, meh
Das Ziel war low-profile, und stellt sich raus, das verträgt sich gar nicht mit through-hole Dioden.  
So wie die auf der Chocofi platziert waren, gab's ein paar Probleme:
![through-hole diode unten](throughhole_on_bottom.jpg)
Unten angebracht, stehen die Dioden weiter ab als die Switches → NG

![through hole diode oben](throughhole_on_top.jpg)
Und oben kommen sich die mit den Switches selbst in die Quere → auch NG

Ich hätte auch flachere SMD Dioden an die Unterseite löten können, aber die wären dann eventuell gegen Dinge gestoßen oder gar abgerissen...  
Also hab ich das PCB Layout revidiert und die Dioden in die LED-Löcher von den Switches geschoben. 
![diode im switch loch](diode_in_hole.jpg)
Die thorugh-hole Löcher für die Dioden mussten auch weg. Damit die Pads auf beiden Seiten trotzdem verbunden bleiben, hab ich die zwei extra Pins von den Switches verwendet, die sonst mit nichts verbunden sind. 
Ich hätte auch einfach Vias einbauen können, aber so hab ich mich viel schlauer gefühlt. 

# Feder Schwip Schwap
In low-profile Tastaturen verwend ich normalerweise die leichtesten[^feder] Switches, die ich finden kann. Die Choc Minis gab's aber nur als ~50g linear und taktil[^clicky].  
Hab nicht rausfinden können was für Federn ich kaufen müsste, oder wo es sowas überhaupt gibt, also hab ich auf gut Glück auch noch normale Choc Blue Switches gekauft und gehofft, dass ich da einfach die Federn klauen kann.  

[^feder]: Federstärke, nicht Gewicht. 
[^clicky]: Angeblich gibt's/gab's auch eine clicky Variante(?), aber hab die nie irgendwo zu kaufen gesehen.

![choc switch innereien vergleich](innards.jpg)

Die Federn von den normalen Chocs *sind* deutlich länger als die Minis, aber passen trotzdem und komprimieren auch nicht 100% vorm Tastenanschlag. Aber auch nur *um Haaresbreite*.  
Hat den Effekt, dass sich die Switches schwerer anfühlen als die normalen Choc blue/pink, aber trotzdem deutlich besser als die Standard 50g Dinger.  

![disassembled switches](switches_disassembled.jpg)
Hab alle auseinander genommen und dann mit de *falschen* Federn wieder zusammengebaut.  
Und 2h später hatte ich dann low-force Choc Minis!

# Ergebnis
Alle teile zusammenstecken war nichts besonderes. Ganz normale Tastatur-Löt-Session.
Aber war's das wert? 

![height comparison](height_comparison.jpg)
(Chocofi mit 15mm links, Minifi mit 11mm rechts)

Sie *ist* flacher als die Chocofi. Um 4mm.  
Also so 27%.  
Über 1/4 weniger. Nicht schlecht!  

Glaube eigentlich nicht, dass das von oben gesehen irgendwem auffallen würde.  
Und in irgendwas eingebaut, das so flach wie möglich sein muss, ist sie auch nicht.  
Aber *ich weiß*, dass sie anders ist. Und das ist genug Daseinsberechtigung, denk ich. So funktionieren Hobbys. 

# Rutschfester Life Hack
Ich hab mir immer schwer getan, gute/billige Gummifüße für solche Tastaturen zu finden.  
Aber hab rausgefunden, dass man einfach ein billiges altes Mauspad nehmen kann, doppelseitiges Klebeband dranklebt und sich dann super rutschfeste, dünne Gummifüße zurechtschneiden kann. Für quasi gratis. 👍

![mousepad-basierte Füße](mousepad_feet.jpg)

# Side Quest: MagSafe Mount

Während ich an dem Ding hier rumgebastelt hab, hab ich im Internet Leute gesehen, die so [MagSafe](https://en.wikipedia.org/wiki/MagSafe_(wireless_charger))-Kram verwendet haben, um ihre Tastaturen auf alle möglichen Arten überall festzumachen.  
Von einfachem Tenting bis hin zu [Tastaturen die mitten im Raum schweben lol](https://www.youtube.com/watch?v=Synej-kIGOs).  

Macht auch Sinn. MagSafe ist Magneten, also einfach ansteck-/abnehmbar, der magnetische Ring ist flach und einfach wo anzukleben, und weil es iPhone Kram ist, gibt's das überall und für wenig Geld.  

Also hab ich mich auch daran probiert. 

Ich hab mir ein Paar simple, billige MagSafe-Tripod-Adapter und Kamerahalterungen (siehe [BoM](#magsafe-bom)) geholt.  

Nichts besonderes.  
Den Metallring befestigen, ohne die Tastatur dicker zu machen, war aber ein bisschen fummelig.  

Die Mousepad-Gummifüße sind ~2mm dick.  
Die Switches schauen ~0.8mm aus dem PCB.  
Und so ein Ring mit seinem Klebeband dran ist knapp unter 1mm dick.  
*Und* die Gummifüße müssen ein bisschen höher sein als alles andere, damit sie noch greifen. Das lässt nicht viel Spielraum  

Das Klebeband auf den Ringen hätte nicht an den kleinen hervorstehenden Flächen von den Switches gehalten, und einfach raue Mängen Kleber draufbatzen wollte ich auch nicht.  

Also hab ich mir eine unnötig spezifische Beilagscheibe gebaut, indem ich einen Flachen Ring modelliert und die gleichen Löcher reingestanzt hab, wie im PCB sind: 
![ring in blender](ring_blender.png)
War in Blender recht simpel. Ein STL aus KiCAD exportiert, in Blender importiert, und dann einfach zusammenge-`boolean modifier`-t.  

Ausgedruckt, und einen *perfekt passenden* Füller gehabt. 
![printed shim in place](ring_on_pcb.jpg)
Fühlt sich gut. 

0.8mm dick ausgedruckt, hat das Ding alles genau auf die Höhe von den Switch Körpern etc. aufgefüllt.  

![MagSafe ring installiert](ring_installed.jpg)

Und dann einfach den Ring draufgeklebt. 

![MagSafe VS Gummifuß Höhe](magsafe_vs_feet.jpg)

Grade noch so mit ein paar Haaren an Spielraum davongekommen. 

... Und es passt alles!  
Die Gummifüße greifen noch gut, die Tastatur ist nicht dicker, *und* ich kann jetzt das damit machen:

![magsafe-montiertes keyboard](desk_mounted.jpg)
Mmh, Ergonomie.


# BoM
- 36x [Kailh Choc Mini (PG1232)](https://chosfox.com/products/kailh-choc-mini-pg1232): ~25€
- 2x [NRF52840-basierte ProMicro-kompatibler MCU](https://www.aliexpress.com/item/1005006271779544.html)[^nnnockoff] : ~15€
- 5x[^minorder] PCB von [JLCPCB](https://jlcpcb.com/) gedruckt: ~10€
- 2x 3.7V 110mAh LiPo Akkus (301230 o.Ä.): ~5€
- 36x kleine SMD Dioden (1N4148W SOD323 o.Ä.): so max. 1€?
- 2x [SMD Ein-/Ausschalter](https://ja.aliexpress.com/item/4000685483225.html): Halber Cent oder so?

## MagSafe BoM:
- 2x [MagSafe<->Tripod Adapter + Magnetring](https://www.amazon.de/dp/B0DM1ZXWT8): ~30€
- 2x [Irgendwelche Montagearme mit Tripodschraube](https://www.amazon.de/dp/B00SIRAYX0): ~30€
- 3D Drucker für PCB-MagSafe Füller Dings

[^minorder]: Braucht man nur 2 aber bei JLCPCB muss man min. 5 bestellen
[^nnnockoff]: a.k.a. [nice!nano](https://nicekeyboards.com/nice-nano/) Abklatsch

# Source
KiCAD Projekt und Gerber Files gibt's im [Minifi Git Repo](https://github.com/Rouji/minifi)
