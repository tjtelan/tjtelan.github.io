+++
title = "A first-timer's perspective to Digital Ocean's Hacktoberfest 2020"
date = 2020-10-05
updated = 2020-10-05
draft = false 
description = "My experience and opinion on my first Hacktoberfest in 2020"
[taxonomies]
tags = ["hacktoberfest", "opensource"]
categories = ["review"]
+++
## So... what is Hacktoberfest?

Digital Ocean’s [Hacktoberfest](https://hacktoberfest.digitalocean.com/) is a month-long event over the month of October aimed at generating an increase of contributions to open source projects. Participants are asked to open PRs against public repositories in Github with “positive contributions”. Swag is offered to the first 70k participants to open 4 qualified PRs.

{{ image(url="https://media.giphy.com/media/l3vRmVv5P01I5NDAA/giphy.gif", caption="A typical hacker", alt="Ed from Cowboy Bebop") }}

## And… how is it going?

I have mixed opinions that honestly, skew negatively. But I feel like I’m more charitable about my feedback than what I've seen on the internet. I’m not intending to drag Hacktoberfest but I’d like to see improvement.

2020 is my first year participating in Hacktoberfest. I’ve already been contributing more to the open source community over the last few years. Particularly for the Rust programming language. I set out to use this event as an excuse to help the Rust community out.

### Positives: 
#### The feeling of a community effort to contribute to Open Source

{{ image(url="https://i.makeagif.com/media/10-05-2020/FTPRH-.gif", caption="A typical open source PR", alt="From Tom Goes to the Mayor into. Shaking hands. Community Spirit") }}

Contributions to open source can happen at any time. I think it’s a nice idea to have a time where people who use open source software are encouraged to contribute meaningfully. Especially for anyone who may feel a bit of intimidation to do so. I’m sure a T-shirt and some stickers can feel very validating to someone who was just using open source before, and now they have some evidence that they contributed too.

#### Discovering smaller projects

{{ image(url="https://media.giphy.com/media/1FXYMTuKX91hS/giphy.gif", caption="Bob Ross had amazing commit messages", alt="Bob Ross. Beauty is everywhere") }}

This was a great opportunity to explore Github for projects that don’t require a lot of experience or commitment in order to help a maintainer out. The repos I offered code to were all small Rust projects that were doing some practical things. It was fun, and I put some effort into what I wrote in addition to having good interactions with the maintainers.

### Negatives:
#### This year’s Hot-fix to the rules and the lack of follow-up communication

{{ image(url="https://media.giphy.com/media/jV4wbvtJxdjnMriYmY/giphy.gif", alt="Spongebob. Communication rainbow", caption="Talk to your community") }}

I feel like the communication around the event is not being managed well. Very reactive, and not effective at spreading the word.

A few days after the start of the event, there was a [significant change in the rules](https://github.com/digitalocean/hacktoberfest/pull/596). I only happened to learn about it through the grapevine, as opposed to from Digital Ocean or through the Hacktoberfest front page or profile pages. Rules feel like they are inconsistently applied, and it feels unwelcoming.

---

Where this change affected me is their change of minimum review times, and probably the validity of my contributions. But I’m confused about what is supposed to apply to me since I had created all my PRs in the first 3 days.

What makes this more confusing is the conflicting information within the Hacktoberfest FAQ.

For example, this is likely some old information about the review time of PRs. States 7 days.

{{ image(path="images/2020-10-05-first-time-hacktoberfest-2020/faq-1.png", width=1600, caption="From FAQ. Review time of 7 days") }}

Later in the same FAQ it says it’s been updated to 14 days. But only those **before October 3, 2020 @ 12:00 UTC**

{{ image(path="images/2020-10-05-first-time-hacktoberfest-2020/faq-2.png", width=1600, caption="Also from FAQ. Review time of 14 days") }}

All 4 PRs were made before this rule change was stated to go into effect (Oct 3 @ 12:00 UTC). The latest being Oct 3 @ 6:26 UTC.

{{ image(path="images/2020-10-05-first-time-hacktoberfest-2020/profile-1.png", width=800, caption="4 PRs. All earlier than Oct 3 @ 12:00 UTC") }}

Changes to the rules could have been communicated somewhere on the profile page in the legend, but were not. Or through email, like the message I recieved when I made my first PR.

I just noticed all my maturation times jump from about a week to about 2 weeks. 3 of these were PRs that were already merged too.

And I’m more annoyed and slightly unmotivated to continue in the event.

(But tbh, rather than feel angry, I’m psyched that I got a few PRs merged so quickly!)

{{ image(path="images/2020-10-05-first-time-hacktoberfest-2020/profile-2.png", width=800, caption="Missed opportunity to communicate that this duration has been updated from 7 to 14 days.") }}

#### Feeling like corporate-sponsored projects are taking advantage of free labor

I think that the core intention of Hacktoberfest is well meaning. But I'm seeing some non-trivial work in big projects labeled for Hacktoberfest.

I’m not personally driven by the swag of a free T-shirt. I just want to help the Rust community and level up my skills while I'm at it. But I feel weird sitting near loud, [negative opinions](https://blog.domenic.me/hacktoberfest/) that I partially agree with. (Although my feelings are a lot more charitable and less intense)

Before [the silent rule changes](https://github.com/digitalocean/hacktoberfest/pull/596), the premise of projects that must opt-out really placed a huge burden on the maintainers of small projects.

{{ image(url="https://media.giphy.com/media/48Osj6XyU0ptQRfh5V/giphy.gif", caption="A typical maintainer during Hacktoberfest") }}

But I’m mostly in my raw feelings, because I feel like the focused energy of the open source community is being taken advantage of by bigger corporate entities for a T-shirt. They are all on the bandwagon to use free energy from eager and inexperienced developers to contribute to their big name-brand projects even though they have their own funding for development.

## But... will I participate next year?

{{ image(url="https://media.giphy.com/media/4TtrENnFsz4EWkU6gz/giphy.gif") }}

Hard to say at this moment, but what incentive do I have? I can contribute any time to small projects, and I most likely will.

The spirit to drive help to small projects is one of my favorite parts of open source, and I think that Hacktoberfest probably started out with that ethos before their audience made it about T-shirts and stickers.

I don’t like the gamified feeling, and maybe that makes this event not for me. The new rule changes will very much change the feel of participation. Probably for the better, since it is opt-in.

---

As I continue to dig into the changes, it appears that there was a [tweet](https://twitter.com/hacktoberfest/status/1312221208667185153) made prior to the changes, but from my perspective, if you didn’t use Twitter and follow [@hacktoberfest](https://twitter.com/hacktoberfest), you’d continue to be lost to the change.

[This message](https://hacktoberfest.digitalocean.com/hacktoberfest-update) appears on their site, but I only got to it through the PR. I don't know how else I would have found it because it isn't on the front page or anywhere I'd easily find.

On one account, I've been told that an email was sent out to highlight rule changes. Pretty late after the fact, but I guess better than. I cannot confirm this myself, since at the time of this writing, I haven't recieved any email regarding rule changes.

---

Depending on how the changes affect the mood and the outcome of this year's event, I could probably warm up to the idea of 2021.

BUT I don’t appreciate rules being changed in such an underhanded manner and without care to communicate them effectively. I expect better communication from a worldwide event.