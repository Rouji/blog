---
title: "200Wh, 100W USB-C PD Power Bank"
date: 2025-02-02T19:00:00Z
draft: true
tags:
  - Unintentional Explosives
cover:
  image: "cover.jpg"
---

I built a ~200Wh, 100W USB-C PD power bank from 18650 cells I had lying around, and a cheap PCB from AliExpress.

BOM:
- 20x 18650 cells: 50€-ish[^cell-price]
- [Nickel strip](https://de.aliexpress.com/item/4000506372982.html): 1€
- [USB-C PD board](https://de.aliexpress.com/item/1005007227510089.html): 15€

Also needed:
- 3D printer and some PLA
- soldering iron
- hot glue gun
- fire extinguisher
- good insurance


# The PCB
![pcb](pcb.jpg)

Available on AliExpress and Ebay and probably other chinesium outlets. 
Listings come and go, but searches for "usb-pd 100W power bank pcb" or some such should do the trick. 
There are a few versions for different battery pack configurations.  

I got the 5S one, since 5 18650s in **s**eries gets you pretty close to the 20V, that 100W USB-PD requires. 
And less voltage difference means more efficient DC-DC conversion. I think.  

Documentation is kind of sparse on these. 
You don't get any in your package, and depending on the online listing there might be a few incomplete JPEGs with tables and machine translated English in them, or none at all.  

There are a few things configurable via resistors/jumpers, which are fortunately all mostly irrelevant for this build. 

![pcb underside](pcb_underside.jpg)

## Capacity Setting

Resistor **R8** sets the capacity of (if I understand correctly) one string of cells. (i.e. the overall capacity of 4 18650s in parallel in this case).  

The documentation JPEGs say:

> | R8 | Cell Capacity |
> |----|---------------|
> | 6.2KΩ  | 5000mAh  |
> | 12.4KΩ | 10000mAh |
> | 18.7KΩ | 15000mAh |
> | 24.9KΩ | 20000mAh |
> | 30.9KΩ | 25000mAh |
>
> Calculation formula: Ω = mAh ÷ 0.8  
> Example: 8000 ÷ 0.8 = 10000 -> 8000mAh = 10KΩ

The pre-installed one is marked `10C`, which is 12.4KΩ.  
For my ~2800mAh cells, it should be `(4 × 2800) ÷ 0.8 = 11200 ÷ 0.8 = 14000Ω`, but I think 12.4KΩ is close enough. And I don't have any SMD resistors anyway.  
This allegedly only affects the percentage readout on the LCD, so you can probably also just ignore it regardless.  

It warns you to not put anything above 30.9KΩ in there. I reckon bigger battery capacity would be fine and it just doesn't like bigger resistor values. 

Also this:
> The maximum charging time is 50 hours, so don't be too big!

The latter half being good general life advice, I think.  
I haven't tested the former. This power bank doesn't take anywhere near that long to charge. 

## Power Setting

**R20** sets the maximum charging and discharging power.  
This should be set to 100W already if you got the 100W version.

{{< details summary="Values Table" >}}
> | R20 | Power |
> |-----|-------|
> | 27KΩ | 65W  |
> | 18KΩ | 60W   |
> | 13KΩ | 45W   |
> | 9.1KΩ | 30W   |
> | 6.2KΩ | 27W   |
> | 3.6KΩ | 100W   |
{{< /details >}}

## Battery Voltage Setting

**R7** sets the "battery type".  
Pre-installed is `27KΩ`, which is 4.2V and already correct for this build.


{{< details summary="Values Table" >}}
> | R7 | Battery Type |
> |----|--------------|
> | 27KΩ | 4.2V       |
> | 18KΩ | 4.3V       |
> | 13KΩ | 4.35V      |
> | 9.1KΩ | 4.4V      |
> | 6.2KΩ | 4.15V      |
> | 3.6KΩ | 3.65V lithium ion phosphate |
{{< /details >}}

## Over/Under Temperature Protection

**R36** sets the temperature protection threshold.  
Again, probably don't need to touch this, but just in case you want to: 

{{< details summary="Values Table" >}}
> | R36 | min. charge temp | max. charge temp | min. discharge temp | max. discharge temp |
> |-----|-------------------|-------------------|----------------------|----------------------|
> | 27KΩ | 0°C | 45°C | -20°C | 60°C |
> | 18KΩ | 2°C | 43°C | -10°C | 55°C |
> | 13KΩ | 0°C | 45°C | -10°C | 55°C |
> | 9.1KΩ[^slowcharge1] | -10°C | 55°C | -20°C | 55°C |
> | 6.2KΩ[^slowcharge2] | 0°C | 45°C | -20°C | 60°C |
> | 3.6KΩ[^slowcharge3] | -10°C | 55°C | -20°C | 60°C |

[^slowcharge1]: this actually says: `-10°C <- 0.2°charge -> 0°C <- normal charge -> 45°C <- -0.1v*N -> 55°C` and I'm not sure what that means.

[^slowcharge2]: `2°C <- 0.1°C -> 17°C <- normal charge -> 43°C` even less sure about this one.
[^slowcharge3]: `-10°C <- 0.2°charge -> 0°C <- normal charge -> 45°C <- 0.2°charge -> 55°C` idk man.

{{</ details >}}

## Ports Aren't Created Equal

![port wattage](port_wattage.jpg)

Not mentioned anywhere is, that only the right USB-C port actually does 100W (charging *and* discharging).  
The other one is limited to 60W, for some reason. Maybe it supports a different set of charging protocols?  

I got very confused trying all kinds of charger/consumer/cable combinations on all the ports until I figured that out ...  


## BMS?

As far as I can tell, this board doesn't do any charge balancing. The JPEGs kind of say as much, and there doesn't seem to be any circuitry for it.  
So the connections going between the series connections are purely for protection.  
Putting a proper BMS between this PCB and the cells seems to be a supported configuration, and might be a good idea. 
I haven't found one I like yet, but will add one when I do.

# The Battery Pack
- rect vs honeycomb
- wiring

- [18650 holder openscad](18650_holder.scad) (I can't for the life of me find the original source, very sorry :/)

[^cell-price]: Rough current price; I had mine left over from a project years ago.
