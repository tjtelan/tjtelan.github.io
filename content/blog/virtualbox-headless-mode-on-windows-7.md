+++
title = "Virtualbox Headless-mode on Windows 7"
date = 2011-03-21
[taxonomies]
tags = ["freebsd", "virtualbox", "zfs"]
categories = ["howto"]

#[extra]
#old-wordpress-comments:
#- id: 2
#  author: Will
#  author_email: silvertoken99@gmail.com
#  date: 2011-04-02 11:30:00
#  content: ! 'I don''t know why I still see this practice...  it''s pointless to call a bat file from your script...  it''s a lot easier if your script is setup to take the VM as an argument then you just point your shortcut to the script with the VM name as an argument and your script calls vboxheadless directly...  like so...
#
#    Set WshShell = WScript.CreateObject("WScript.Shell")
#    cmd = chr(34) &amp; "C:Program FilesOracleVirtualBoxVBoxHeadless.exe" &amp; chr(34)
#    &amp; " -s " &amp; wscript.arguments(0)
#    obj = WshShell.Run(cmd, 0)
#    set WshShell = Nothing
#
#    Now you just create a shortcut that points to this VBS file and add the name of the VM at the end of the target line..'
#- id: 3
#  author: telant
#  author_email: tj.telan@ieee.org
#  date: 2011-04-02 14:45:00
#  content: ! 'You''re right. Using two files is pointless and your approach is much more straightforward.
#
#    The reason I call the bat file from my script is because I wrote the bat file first. I thought I would be able to use it at startup like scripts in linux but that didn''t quite work as expected.
#
#    Thanks for the tip!'
+++
An impromptu reformat of my Windows 7 machine quickly had me frustrated with Virtualbox reconfiguration. It had been so long since I had originally done it, and I had forgotten to document the nuances of that setup. So here goes\:

## Purpose

This specific VM configuration is FreeBSD 8.2 w/ ZFS on root. I don't have the time to set it up from scratch, but I'm currently using the newest ZFS version available on [this site][mfsBSD] (v28, special edition).

I'm only planning on using this VM for SSH for a persistent irc connection. I also want this to start automatically at Win7's boot.

## Install VM

So after installing FreeBSD and ports and of course, remembering to *ENABLE SSH*... I had to test the ssh connection.

(Remember to open the ports on the host side. I'm not going to walk you through that step.)

## Headless VM

Now for the headless start.

I tried creating a .bat file that used `VBoxHeadless`. This let it start at boot, but it left an annoying cmd.exe window open.

Apparently a common issue. A common solution I used was to create a .vbs script to run the .bat file. This was both annoying and tedious but effective. Startup at boot and no lingering cmd.exe window.

Here are the contents of my .bat and .vbs files. I placed these in the same directory, and made a shortcut in the `Start > All Programs > Startup` to the `.vbs` file.

### startfreebsdvm.bat

```bat
D:\"Program Files"OracleVirtualBoxVBoxHeadless.exe -s FreeBSD startvm-headless.vbs
Set WshShell = WScript.CreateObject("WScript.Shell")
obj = WshShell.Run("D:Users[username]startfreebsdvm.bat", 0)
set WshShell = Nothing
```

[mfsBSD]: http://mfsbsd.vx.sk
