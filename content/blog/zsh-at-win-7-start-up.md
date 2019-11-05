+++
title = "Zsh at Win 7 Start up"
date = 2011-03-28
[taxonomies]
tags = ["cygwin", "scripting", "startup", "windows"]
categories = ["howto"]
+++
Beginning of the quarter is tomorrow, and I'm trying to accept that I will be spending more time on a Windows workstation to access the software I'm using for my senior project (more on that soon).

There are a few comforts that I am still missing in Win7 that I'm trying to solve with Cygwin, like [Improving Cygwin in Windows with Rxvt](@/blog/improving-cygwin-in-windows-with-rxvt.md) getting zsh back.

Today, that issue was being able to write Zsh scripts that would run at login through Cygwin instead of using cmd.exe.

Turned out to not be quite as straightforward as I had hoped, but still easy.

## Add Cygwin to Win7 PATH environment variable.

It took me a moment to find this information after having trouble using `ls` in my script. Although, `echo` worked...

Anyway, might as well add this first and avoid the issues entirely.

* Open start menu
* Right-click `Computer`
* Click `Properties`
* Click `Advanced system settings`

In the new `System Properties` window, click the `Environment Variables` button located at the bottom.

In the new `Environment Variables` window, at the bottom are the `System variables`
Add `CYGWIN_HOME` with a value of the Cygwin installation path (default is `C:/cygwin`) if it does not exist in the variable list.

Edit the `PATH` variable to include `%CYGWIN_HOME%/bin` which is the same as
including `/bin` in the Cygwin environment.

## Run Cygwin scripts from Windows

You can't just write the script and use Zsh built-ins in Windows space. You have to write the script in Zsh space and have windows have Zsh run that script. Simple. Right?

I'll just show my test scripts:

*(On the Windows desktop)*

testscript.bat
```bat
zsh.exe /home/[username]/test.sh
```

*(In Cygwin)*

test.sh
```sh
#!/usr/bin/env zsh
echo `pwd`
echo Test
echo `ls /home/[username]`
```

These are the results of running testscript.bat in cmd.exe

```bat
/cygdrive/d/Users/[username]/Desktop
Test
test.sh
```
