+++
title = "My blogging history and how I am now using Zola, docker and Github Pages to run my website"
date = 2020-04-27
draft = true 
description = "My history with various blogging platforms, and how I make it work with Zola and Github Pages"
[taxonomies]
tags = []
categories = ["now-blog"]
+++

This post is going to focus on the tools I rely on to run my blog. I'm first going to go into the history of how I got to my current stack, so you can skip ahead [to the present day](#the-present-day) if that does not interest you.

## History

I first started hosting my blog on my own Wordpress site when I was in school. I chose the self-hosted route because I was new to the industry and my employer at the time ran a few instances that I was managing. It was what I knew how to use and self-hosting allowed me a lot more flexibility with plugins and themes than the free, SaaS instance at the time. This was successful until my site was hacked and bots would create more cleanup work than the writing. At this point I was newly graduated and my new employer was actively discouraging with me writing about what I work on. So rather than work around that potential friction, I took my site down. 

A few managers later and I got back into the flow of documenting. Static site generators were now a thing. I got my feet wet trying out Jekyll. I was not really familiar with Ruby and the tools in that ecosystem, but it almost didn't matter. I was able to focus on writing, and it was at least possible to run a local instance at home to test before pushing compile sites out to my VPS. Jekyll is blog focused, and it was a nice step ahead Wordpress in terms of keeping content organized by date, and sortable by a variety of metadata. Not needing to run a local LAMP stack and all of the other Wordpress requirements was a huge plus.

After running Jekyll for a year or so, Zola (at the time Gutenberg) came along. As a Rust enthusiast, I wanted to support the applications written in Rust. So for no reason other than being in Rust, I switched over to Zola.

## The Present Day

