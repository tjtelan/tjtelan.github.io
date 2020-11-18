+++
title = "Is DevOps Automation a zero-sum game?"
date = 2020-11-10
updated = 2020-11-10
draft = false 
description = "Discussion about whether DevOps culture requires winners and losers"
[taxonomies]
tags = ["devops"]
categories = ["discuss"]
+++

[Link to the original discussion on Dev.to](https://dev.to/tjtelan/is-devops-automation-a-zero-sum-game-3dg7)

---

Some of my intention is to lean into the ambiguity of the definition of DevOps.

In general, when automation is created and introduced into an organization for the purposes of "progress" for a wide audience, is this improvement gained at the expense of an individual or a team?

---

Here's a made up example. Automatic alerts in a production environment of a web app for a small US company's online order form.

The primary customer live in US timezones. The assumed culture is that outages are to be avoided. 24/7 uptime.

Before alerting was introduced in this org, outages in production might not be known until traditional work hours when more complex workflows.

After alerting was introduced, the possibility of non-work hour wake up calls from alerts increased significantly. On-call/event-based compensation might balance the fairness to the person responsible, but that's a monetary cost paid from the org to offset a forced work-life cost.

In my opinion, the introduction of automation led to compromise by the individual, with practically no benefit to the business to make no change.
