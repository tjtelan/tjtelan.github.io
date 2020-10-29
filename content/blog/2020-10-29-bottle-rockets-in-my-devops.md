+++
title = "Bottle rockets in my DevOps? It’s more likely than you think."
date = 2020-10-29
updated = 2020-10-29
draft = false 
description = "Why DevOps thinking is not new. A story that demonstrates the benefits from outside the software industry"
[taxonomies]
tags = ["devops"]
categories = ["devops"]
+++
Why is DevOps such a hot trend when many find it hard to concretely define? It is just for big companies? Could you be practicing DevOps as a small software organization and not even know it? What are the outputs of DevOps activities? How do you explain DevOps to your less-technical colleagues?

To help address those questions, I want to tell you a story not about software, but instead about bottle rockets. We’ll take a look at typical DevOps activities and how feedback loops can naturally form and provide opportunities for improvement using DevOps thinking.

---

Imagine you are building a company that makes and shoots off fireworks. You’re just starting out, so you’re the one making the fireworks.

The firework is aimed, a fuse is lit, the rocket launches, and features are displayed to your customers. You intentionally design pyrotechnics with an expected outcome. Your customers love the loop-de-loops, whistling, and colorful sparks!

At first, you’re just building customized fireworks by yourself with cheap kits. Based on positive feedback from customers, you start to develop a specific type of firework. 

_This is essentially how all software products start._

You soon outgrow the capabilities and customizability offered through the kits, and to save on money you develop your own process using raw materials. You build and package every single unit in your garage, and have fireworks shows in a field next to your house. People are buying tickets to your fireworks shows, regardless of how the product was built -- they just want a cool explosion (and yours are the coolest). 

What your audience doesn't see are the many experiments and failures that went into building their experience. However, since you work alone, any mishaps are in your private space and they are easy to put out with a fire extinguisher and a bucket of water.

_This is similar to software development._

Your company wants to expand their market size and offerings. You hire new people to help you build more of what currently sells, as well as help create new designs based on feedback from customers. Building in your garage no longer suits the needs of the business. 

_This is similar to the start of [some](https://www.geekwire.com/2014/amazon-20-years-garage-startup-global-powerhouse/) [legends](https://news.microsoft.com/announcement/microsoft-is-born/) in [software](https://en.wikipedia.org/wiki/HP_Garage) [development](https://mashable.com/2013/09/27/google-garage-anniversary/)._

You move into a bigger warehouse with an indoor launchpad. You teach the new people how you work. You build and package units by hand. The new people are not as good at this as you are and they don’t have your intuition, so the quality of output is not as consistent. 

You’re now launching your bottle rockets from inside the warehouse, through a window. The inconsistencies sometimes cause a small fire so everyone has to stop what they’re doing to help put it out.

You spend the money or time and effort to create special tools so that they don’t needlessly make mistakes.

_This is similar to **dev tooling**. Dev tooling is domain-specific software or automation created for the purpose of helping developers keep their focus on the details of their problem. It also helps developers to offload the mental burden of tedious tasks such as data processing, reformatting, or validation, onto their tools._

Your company now creates many different types of fireworks, and has showcase displays every week. Every product uses specialized parts so it can be a scramble to get everything done in time. One of your new bottle rocket designers discovers that with a few small modifications, many of your products could use the same, adjustable fuse. Now, many firework designs can be made at the same time, and each fuse can be adjusted in the field prior to ignition. You apply this strategy to other parts and this improves your manufacturing efficiency.

_This is similar to **microservice architecture**, a style of service-oriented architecture design that enables an application to be composed of several small modules organized by business capabilities. These modules can be developed and updated ad-hoc without requiring a full redeployment of all components._

You get late notice there’s going to be a huge fireworks expo very soon, and your company’s unique fireworks will be the star of the show. 

You return to the product lines to assist with packing units. It’s a terrible experience. 

The work is manual, and for some of the tasks you realize that the same tools can be used by an assembly machine and performed with more precision and consistency. With some extra effort, more machines could be constructed to create units for quality control testing, and package units for shipping. The process of assembly, packing, and launch preparation is now more standardized, and your human workers can focus on designing better fireworks instead of remembering the exact order and specifications of assembly.

_This is similar to **CI/CD** (continuous integration / continuous delivery/deployment). CI/CD is a process that connects development (writing the code) to operations (running the code)._

_Typically initiated by a developer pushing code, which builds, tests. This process is called Continuous Integration (CI). The end of a CI process that results in an artifact ready to be deployed is called Continuous Delivery. Going one step further to an automatic deployment of the artifact into production is called Continuous Deployment._

As your rockets get bigger, you notice that the aiming from the launchpad isn’t going as well as it used to. With the smaller rockets, you were able to eyeball the right trajectory, but this isn’t working as well with these more complex fireworks. Due to your previous standardizations of fuses, the same fuse modules are used for all the rockets. Therefore we can narrow our investigation of the trajectory issues specifically to construction of the complex fireworks. Quality control is now also improved because there are fewer variants introduced. Changes are easier to track and correct using information from internal quality control and from customers.

_This is **observation through metrics and monitoring**. The trajectory was noticed not only holistically because of regular launches internally, and by customers. But also objectively, because we’ve collected data on the distances experienced in a variety of conditions._

You’re building bigger and better bottle rockets, and your customers are thrilled with the exciting displays you’re putting on! They’ve never seen brighter colors or more interesting designs!


## Conclusion

Using this somewhat silly story as a stand-in for the software development and deployment process, you can see that DevOps activities are often part of a developing and growing system. With every deployment, you’re trying to shoot a bottle rocket out of the window. 

Picking and choosing DevOps activities to optimize is normal for small but growing software organizations. Be pragmatic. Adopt solutions when you have problems they solve. 

So how do you know what you actually need? You’re likely already addressing the needs you have (but in a much less efficient way). Interested in investing in your team’s DevOps practice? Here are some starting points to think about:



*   If your team spends a lot of time moving between projects, consider bulking up your **dev tooling**.
*   If you frequently find yourself solving the same problem repeatedly or copy/pasting and lightly modifying service code, investigate implementing **microservice architecture** to do that job for you.
*   If you rely on a single developer’s machine or struggle to consistently build or release minor changes, **CI/CD** could be what you’re missing.
*   If you make changes based on feelings and not with data, then improve your product observation through collecting **metrics and monitoring**.

A cohesive strategy for packaging, deployment, and response is essential as growth occurs. As the rate of updates increase, the rate of outage-causing failures climbs proportionally. 

It is fatally optimistic to rely on the hope that your product is absent of critical bugs. Reactivity is not a dependable plan, especially in the high-stress situations caused when your bottle rocket explodes on the launchpad. Instead, assume that things will inevitably go wrong sometime, somewhere. Create tangible strategies that bridge writing code (development) and running code (operations) through common language and goals, and rely on procedures that considered the important details back when stress levels were not high. 