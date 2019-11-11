+++
title = "Writing more Rust, and updating static blog site to Zola 0.9.0"
template = "now.html"
date = 2019-10-10
+++
[Rust v1.39](https://blog.rust-lang.org/2019/11/07/Rust-1.39.0.html) released with stable Async/Await, and I've been getting familiar with writing new code to utilize it. My experience migrating [OrbitalCI](https://github.com/level11consulting/orbitalci/pull/230) libraries from using Tower-grpc to Tonic (which uses Async/Await) resulted in much nicer to read code, in my opinion.

It has also been a while since posting anything, so I haven't been keeping my static site tools up-to-date, until now. There was a little bit of an effort with updating templates and internal links, but I've moved off of 0.4.2 (back when the site generator was called Gutenberg) to the newest Zola 0.9.0 release.
