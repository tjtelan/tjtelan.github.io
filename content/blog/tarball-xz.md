+++
title = "Tarball xz"
date = 2011-08-31
categories = "howto"
tags = ["bsd", "linux", "portable", "xz"]
+++
At work I manage a handful of servers running FreeBSD. Today I was writing a little backup script where I wanted the output to be an xz compressed tarball.

[Link to xz Wikipedia article][wikipedia-xz]

Arch Linux's packages are delivered as tar.xz, and the compression rate is better than gzip and bzip2.

I thought this was going to be pretty straightforward, but I was mistaken. Turns out that the BSD tar implementation of tar does not transparently support xz compression in the same way GNU tar implements it. (I'm not saying that it isn't supported, but -z gzip / -j bzip2 / -J xz is easier to remember).

Being in a particularly untrusting mood towards tar, I figured I would write a portable one-liner that I could use on work servers and on my workstation.

Here goes...

```sh
tar -cf - {PATH_TO_ARCHIVE} | xz -2ec > {PATH_TO_SAVE_TARBALL}.tar.xz
```

[`-2ec` refers to extreme compression level 2, which works for me in this case. Refer to the xz manpage for more info.]

[wikipedia-xz]: http://en.wikipedia.org/wiki/Xz
