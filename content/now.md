+++
title = "Trying new things"
template = "now.html"
date = 2021-02-21
+++
Been a long time since I made an update on what is going on. The short: I'm trying to figure out the pace for creating content for 2021.

---

I haven't been streaming because my available schedule is changing to accomodate new projects (that I'm not ready to talk about yet). It is giving me a lot of opportunity to build deeper understanding of coding in Rust. However, I want to give myself a chance to succeed before returning to Twitch/YouTube.

---

Still working on Orbital though. Orbital is starting to reach an important stability milestone. I believe it will soon be useful for my personal usage, which I think will help accelerate development.

---

Last topic I want to share. I've been pulling out more of Orbital's git workflows with the [git2](https://crates.io/crates/git2) crate into multiple crates.

* [git-meta](https://crates.io/crates/git-meta)

Git-meta is an higher-level abstraction layer for working with git repos on your local machine. Most people don't need to know the internals of git in order to use it. I am hoping this can be a library that simplifies using git to the mental model most people have.

I wrote it so I could clone/open repos, and look at branches, and a few details about specific commits. Details such as its hash, its commit message and what files have changed.

Also you can check on whether new commits exist at your git host that have not yet been pulled in.

* [git-event](https://crates.io/crates/git-event)

Git-event is an application using git-meta in order to enable other developers to create their own git-ops workflows. That is, they will be able to watch a repo and run their own code whenever a new commit is found. (Or if new commits change specific files or within paths)

Orbital's polling functionality uses git-event in order to start new builds.