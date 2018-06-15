+++
title = "Laptop Volume Buttons in AwesomeWM"
date = 2011-09-15
#categories = "How-to"
#tags = ["awesomewm", "laptop", "rc.conf", "volume-control"]
+++
I've been using [Arch Linux][arch-linux] on my laptop for a while now running [Awesome][awesomewm] as my window manager.

I've have struggled to find the motivation to actually fix minor inconveniences because of the workarounds that I always seem to find first.

In this post, the inconvenience that I ended up solving is one that laptop users take for granted: the keyboard volume controls.

Initially, I just had trouble getting sound working. Turns out that I just
[needed to unmute][arch-wiki-sound].

Just being overwhelmed by how much I need to read just to return some basic niceities back to my laptop usage, I've defaulted to the command line methods of doing what I need to do rather than read new documentation.

So that means that I've just been using `alsamixer` whenever I needed to control my volume since my volume keys did not have any function.

It turned out to be very simple. I just had to add a few lines to my awesome config file (`rc.lua`).

```lua
awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -c 0 set Master toggle") end),
awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -c 0 set Master 2+ unmute") end),
awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -c 0 set Master 2-") end)
```

These went at the bottom of the globalkeys section in the rc.lua file. I'm not going to cover rc.lua, because if you don't know, then you really need to catch up on some documentation or you will probably screw things up.

I got the XF86\* names by running `xev` and pressing the buttons. The amixer command `-c` flag is specific to my needs, so beware before copy/pasting.

When I get more comfortable with editing rc.lua, I plan on making a more detailed post.

Just taking a break between writing my review for my MetaWatch. Coming soon, I promise.

[arch-linux]: http://www.archlinux.org
[awesomewm]: http://awesome.naquadah.org
[arch-wiki-sound]: https://wiki.archlinux.org/index.php/General_recommendations#Sound 
