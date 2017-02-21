---
layout: post
categories: info
tags: [adb, android, honeycomb]
---
So, I got this tablet from school to work on a few of my projects. I have to give it back at the end of the quarter, but right now I'd happily give it back. I'm not impressed. It is neat, but I wouldn't pay the $800 retail price.

"I got the new XOOM tablet with Android Honeycomb and it is just ok."

I was the first person to turn this thing on, so the first thing I did was measure the response time for reorienting the screen when it is rotated.

2 seconds. Much too slow.

I'm also having some issues getting the debugger to recognize that I've got it plugged into my laptop.

I've already added another entry in udev. I have no idea what I'm doing, so I based it off of the rule I made for my G2.

Ubuntu 10.04, btw

    % cat /etc/udev/rules.d/51-android.rules
    SUBSYSTEM=="usb", SYSFS{idVendor}=="0bb4", MODE="0666"
    SUBSYSTEM=="usb", SYSFS{idVendor}=="22b8", MODE="0666"
