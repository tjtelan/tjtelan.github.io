+++
title = "Improving Cywgin in Windows with rxvt"
date = 2011-03-18
[taxonomies]
tags = ["cygwin", "putty", "rxvt"]
[extra]
summary = "Configuring Cygwin + terminal emulator in Win7"
+++
I've grown accustomed to using a terminal emulator pretty much any time I sit down to use the computer.

Most of the time I am using my laptop, which is running Linux (Ubuntu, at the moment). I've already got that workstation set up mostly how I like it. But lately I've been using my Windows 7 desktop a lot more for school related (and gaming related) things.

I use SSH all the time, and when you are using Windows, that means that your choices are limited when looking for a decent SSH client. The only choices I'm going to be considering are Cygwin and PuTTY.

## PuTTY
PuTTY is alright, but these are the issues I've had with it:

* Copy/Paste functionality is different.
* Highlighting text auto-copies to clipboard. Right click auto-pastes into the console.
* No simple way to set up passwordless login using SSH keys


## Cygwin
The learning curve for Cygwin is a little steep, but the issues I've had
with it (without rxvt):

* Runs **inside** cmd.exe
* Cannot resize the window larger than default size without messing with cmd.exe window properties
* Copy/Paste is too difficult to use
  * Attempting to highlight text does nothing unless you are in 'mark mode'. Figure that out.
* Can't place shortcut in taskbar
  * Because the shortcut to cygwin is to a \*.bat rather than \*.exe

**So what is the solution to this mess?**

# Cygwin + Rxvt

* Install the *rxvt* package with the cygwin installer
* Create shortcut for rxvt

You can choose your own colors, fonts, and login shell

Here is the path I used in my shortcut:

cygwin-rxvt-launcher:

```cmd
D:\cygwinbinrxvt.exe -sr -sl 2500 -sb -geometry 90x30 -fg green -bg black -tn rxvt -fn "Anonymous Pro-16" -e /usr/bin/zsh --login -i
```

Here, I'm using green text, black background and my favorite monospaced font, [Anonymous Pro][anonpro], at size 16 with Z-shell as my login shell.

Took me a moment to figure out copy/paste, but here is how you do it. It is an improvement, but not perfect\:

**Copy**:
Same as PuTTY. Highlight using mouse to copy text to the clipboard

**Paste**:
Hold down *Shift* and *left-click* with your mouse.

[anonpro]: http://www.ms-studio.com/FontSales/anonymouspro.html

