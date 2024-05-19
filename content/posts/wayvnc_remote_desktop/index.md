---
title: "Mimicking Windows RDP Behaviour on Linux"
date: 2024-02-23T22:29:00Z
draft: false
tags:
  - linux
  - wayland
  - sway
---

Windows remote desktop is actually kind of neat.  
Lets you pick up a local session remotely, while keeping the local console locked and even adapting to your remote display's dimensions.  
VNC can give you access to a running Linux session, but doesn't normally do those other two things.  

I have a big beefy desktop, but also like to work on my laptop. I also like continuing my big beefy desktop stuff just the way I left it. 
Windows' remote desktop would be perfect for this, but I'm a penguin. So I'm make do with what I've got. Which is VNC and hacky stuff. 

# HEADLESS Outputs to the Rescue
[wlroots](https://gitlab.freedesktop.org/wlroots/wlroots)-based Wayland compositors (in my case, [Sway](https://swaywm.org/)) can make use of a "virtual output" feature (sway calls them "headless"). 
It lets you add outputs to a session, that get rendered and behave like any normal output, but lack a physical display to output to. 
That includes all of your normal acceleration and 3D rendering and stuff. 

So the idea is using those and kind of cobbling together the missing behaviour somehow ourselves. 

## The Networked Extended Desktop
Creating a headless output and running [a VNC server](https://github.com/any1/wayvnc) on it is easy enough. 
```bash
swaymsg create_output
swaymsg -t get_outputs  #Probably tells you you now have an output called HEADLESS-1
swaymsg output HEADLESS-1 resolution 1920x1080
wayvnc -o HEADLESS-1 0.0.0.0
```
And you now have an extra screen you can't see. But if you connect to that VNC server from another PC, you *can* see it there.  
This is essentially something like Apple's [Sidecar](https://support.apple.com/en-us/102597), which is a pretty handy thing already. 
Just get a VNC app for your tablet or whatever and have more screens!

## "Locking" the Local Console
The extended desktop is already pretty good, but if you can't see the remote PC's screen, you have at least one workspace there you can't really interact with. 
And other people can see/interact with it. 
I mainly just want all the things moved to the VNC client's view. 

Turning off the physically attached outputs accomplishes that. 
```bash
swaymsg output DP-1 disable
```
Congrats! For a manual solution, you're done.  
Just remember to undo all of this before turning off the laptop, because your desktop now doesn't output any video. 

**NOTE:** This isn't secure, because input from local input devices still goes through. 

# Scripting it
Making this setup repeatable and reliable is a bit fiddly. Mainly because you can't choose the name for the headless output; 
they just start at HEADLESS-1 and then count up from there, even if you destroy one before creating the next.  
Also disabling/enabling all non-headless outputs generically. 

`~/bin/start_wayvnc`
```bash
#!/bin/sh
OUTPUT=$(swaymsg -t get_outputs | grep -oE 'HEADLESS-[0-9]+')
if [[ -z "$OUTPUT" ]]; then
    swaymsg create_output
    OUTPUT=$(swaymsg -t get_outputs | grep -oE 'HEADLESS-[0-9]+')
fi

swaymsg output $OUTPUT resolution 3840x2160
swaymsg output $OUTPUT enable
swaymsg output $OUTPUT power on

swaymsg -t get_outputs | jq --raw-output '.[].name' | grep -v HEADLESS | while read TO_DISABLE; do
    swaymsg output "$TO_DISABLE" disable
done

exec wayvnc -Ldebug -g -o $OUTPUT -r 0.0.0.0 5901
```

`~/bin/stop_wayvnc`
```bash
#!/bin/sh
killall wayvnc

swaymsg -t get_outputs | jq --raw-output '.[].name' | grep -v HEADLESS | while read TO_ENABLE; do
    swaymsg output "$TO_ENABLE" enable
done

swaymsg -t get_outputs | jq --raw-output '.[].name' | grep HEADLESS | while read TO_UNPLUG; do
    swaymsg output $TO_UNPLUG disable
    swaymsg output $TO_UNPLUG unplug
done
```
(Having wayvnc not on default port 5901 is intentional)

# Automating it
Already pretty good. SSH in, `start_wayvnc`, VNC in, do some work, `stop_wayvnc`, done.  
>But with Windows all you have to do is connect via RDP, zero setup!

Socket activation it is.

Just your average systemd service `~/.config/systemd/user/headless-output-vnc.service`
```ini
[Unit]
Description=Headless sway output with wayvnc on it

[Service]
ExecStart=sh -c "exec $HOME/bin/start_wayvnc"
ExecStartPost=/bin/sleep 1
ExecStopPost=sh -c "exec $HOME/bin/stop_wayvnc"

[Install]
WantedBy=default.target
```
There's no readiness feedback between wayvnc and systemd. Without the `sleep 1`, systemd's socket gets connected to wayvnc, before it's ready and the whole thing fails.  

wayvnc doesn't do socket activation, so we need a [proxy](https://www.man7.org/linux/man-pages/man8/systemd-socket-proxyd.8.html): `~/.config/systemd/user/proxy-to-vnc.service`
```ini
[Unit]
Requires=headless-output-vnc.service
After=headless-output-vnc.service
Requires=proxy-to-vnc.socket
After=proxy-to-vnc.socket
PropagatesStopTo=headless-output-vnc.service

[Service]
ExecStart=/usr/lib/systemd/systemd-socket-proxyd --exit-idle-time=3s 127.0.0.1:5901
```
The `Requires`/`After`/etc stuff was a bit of trial and error. Don't ask.


And the socket itself `~/.config/systemd/user/proxy-to-vnc.socket`
```ini
[Socket]
ListenStream=5900

[Install]
WantedBy=sockets.target
```

# Random Notes
- I use [TigerVNC Viewer](https://github.com/TigerVNC/tigervnc). Seemed the best in terms of image quality/speed/stability. Honourable mention: [wlvncc](https://github.com/any1/wlvncc)
- You need some kind of ["passthrough" mode](https://github.com/any1/wayvnc/blob/5d55944dab7c395658f40fc4217146852447d513/wayvnc.scd?plain=1#L414), if you VNC into a sway session from a sway session.
- You can do this on completely headless servers as well, for a kind of VDI solution, that can game. Use steam's streaming feature or something instead of VNC if you do want to game headless though. 
