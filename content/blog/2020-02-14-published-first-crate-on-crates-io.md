+++
title = "Published First Crate on Crates.io"
date = 2020-02-14
draft = false 
[taxonomies]
tags = ["rust", "how-to", "crates.io"]
+++
I published [my first public crate](https://crates.io/crates/git-url-parse). I thought my library was useful, general, and did not have a similar implementation in crates.io. I hoped that it may get used by the Rust community. It turned out to be very easy to package and upload my code, and I wanted to share my process.

## Complete Cargo.toml with package metadata

https://doc.rust-lang.org/cargo/reference/manifest.html#package-metadata

I tried to define the metadata completely. Other than writing the code, this took the longest time. I wanted to make sure the crate listed in an appropriate category. As well as using relevant keywords.

(My very first version did not have a README or fancy build badges, but I did have docstrings for docs.rs)

## Generate API Key and log in from cargo

Crates.io only supports logging in using Github accounts.

Navigate to Account Settings and scroll down to the *API Access* section. Click new token and give your token a name.

After giving your token a name, there is going to be a `cargo login` command with a random token value. Run this command to log in.

## Run cargo publish

My crate was at the top of the new crates column of crates.io

Like I mentioned earlier, I had doc strings in my code that I expected to publish to docs.rs. This can take a few minutes. Wait a few minutes. It’ll make it there.

I later followed up with writing a complete README.md, and added badges. That’s all it took to make my little library look fancy.

If you were on the fence about publishing to crates.io, I hope you are now convinced that it was not.

---

#### Before you go, some info about my crate:
[git-url-parse](https://crates.io/crates/git-url-parse).

I wrote it because common ssh-based git repo urls don’t fit a standard like:
* [the living URL standard](https://url.spec.whatwg.org/)
* [RFC 1738](https://tools.ietf.org/html/rfc1738)
* [RFC 1808](https://tools.ietf.org/html/rfc1808.html)
* etc.

As such, parsing is not supported by many languages’ standard library, including Rust.

Anyway, I hope you'll check it out! Thanks!