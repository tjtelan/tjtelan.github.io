---
layout: post
categories: [info, preview]
tags: [firmware, metawatch, raspberry-pi, defcon, ubuntu, code-composer]
---
Alright, so it has been a while since my last post. Life came up and development slowed down a bit, but here is what is up:

# MetaWatch

However, I finally got around to playing with the free firmware development options that have opened up. TI's Code Composer IDE is available to MetaWatch developers for free (kind of), and there is Linux support available!

I wasn't able to get CCS installed and running in my Arch Linux environment, but there were instructions for the Ubuntu and Fedora distros. I took the time to install Ubuntu 12.04 (because I'm impatient and this is easy) in a VM with the hopes that I could use USB passthrough to develop and flash the firmware. It just couldn't be *that* easy, but fortunately (Thanks to the MetaWatch forums!), I can now compile and flash my watch with my own custom firmware using a process that is less painful than I'm about to explain\:

Compile in Ubuntu (Guest VM) -> scp the firmware to the Arch (Host) -> use mspdebug to flash onto watch

When I get the time, I'll set up the "sharing folders" options so I don't have to manually copy between the virtual divide.

The only problem I'm having with my firmware is MetaWatch Manager connectivity issues. I just plain can't connect using what I've compiled. I'm feeling like I'm the only one having these problems since I haven't heard any complaints on the forums. I'm hoping to have something more exciting about that soon.

# Raspberry Pi

I finally got mine a few weeks ago, but it has been sitting in the box. I plan on playing around with this to see if this lives up to my expectations. It is really popular on Hack-a-Day lately, so I'm hoping I can have something to contribute to the flood of projects popping up on the internet.

# DEFCON 20

Soon I'll be going to brave the summer Las Vegas desert for the first time in honor of DEFCON. I'm not sure what to expect, but I've been looking forward to going for a long time.
