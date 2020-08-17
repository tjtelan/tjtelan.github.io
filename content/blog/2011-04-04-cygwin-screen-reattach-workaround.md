+++
title = "Cygwin Screen Reattach Workaround"
date = 2011-04-04
description = "Workaround for reattaching Tmux session in Win7"
[taxonomies]
tags = ["cygwin", "gnu-screen"]
categories = ["how-to"]
#[extra]
#comments:
#- id: 5
#  author: wszebor
#  author_email: radovan@op.pl
#  date: 2011-07-11 01:49:00
#  content: Confirming that this works (Win 7, Cygwin 1.7.9, screen 4.00.03)!
+++
In an [earlier post](@/blog/2011-03-21-virtualbox-headless-mode-on-windows-7.md) I mentioned how I was using a VM for my irc usage. I was running GNU screen + irssi to keep a persistent connection so I can idle in channels.

I've been experimenting with using Cygwin to make my Windows 7 machine my SSH box. So I installed irssi + screen... Looks like everything is all good.

(BTW: If you use a terminal emulator and you haven't looked into GNU screen, I really recommend that you do.)

However, I've been bumping into issues with reattaching. After running both screen `-DR` and `-DRR` just hung there.

Quick search for a solution led me to [this workaround][cyg-workaround

```sh
#!/bin/sh
# Send SIGHUP to each screen to force it to let go and let the server recover
ps -as | grep screen | cut -c4-7 | xargs kill -1
# Reattach
screen -xRR
```

This works for me. I'd like to not have to go through all the extra trouble, but it is pretty slick.

[cyg-workaround]: http://cygwin.com/ml/cygwin/2010-03/msg01026.html
