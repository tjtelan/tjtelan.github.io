+++
title = "DevOps Helps you be a Better Leader"
date = 2020-11-06
updated = 2020-11-07
draft = false 
description = "This is the first of a series about helping your organization embrace DevOps"
[taxonomies]
tags = ["devops", "leadership", "management"]
categories = ["devops"]
+++

*This is the first of a series about helping your organization embrace DevOps.*

## DevOps is misunderstood
DevOps is buzzwordy – so hot right now. Like all tech development trends, everyone wants it, but everyone also has their own ideas about the kind of problems it will solve. This is a precarious situation, because a lot of people aren’t wrong. But they are unaware that their version of the truth is so narrow that they end up missing the big picture.

In this post, I’ll discuss DevOps at a high level by addressing: 

* What is (and what isn’t) DevOps
* How DevOps differs from the “normal” development process you may already have
* How practicing DevOps can reduce time and money required for development and operations
* How nurturing a DevOps culture will increase the quality of life for everyone working on your product

There are many more topics to discuss, but we must stay focused! This should lay the foundation to allow for constructive conversation about how DevOps works in your organization. 

### Who should read this post?
This post is primarily intended for people who need to know the purpose of DevOps because they’re managing a team or hiring for a DevOps skill set. You also might find it helpful if you’re just wondering what DevOps is all about as a developer, operator, student, or in a related, non-technical role.

### Conventions and Definitions
Let’s start with some definitions and conventions so we’re on the same page.

**Environment** or **space** may be used interchangeably. It refers to the location where code is being executed. A laptop or workstation are examples of environments that we can physically touch. But Kubernetes, or “the cloud” are examples of more abstract environments.

**Development environment** will refer to any environment that is primarily used by a single person for the purposes of writing code, such as a laptop or a workstation.

**Production environment** will refer to any environment that is shared, regardless of whether external customers are using it. An internally used environment used only for testing purposes is a production environment. Big differences between a development environment and a production environment may be complexity or scale at which components are deployed. As well as the amount of targeted automation to perform changes such as deployment or collection of analytics. 

**Development** *(Dev)* is a phase and a team we associate with writing code. Specifically, it refers to code that has not yet been released officially to a wider audience. When a project is in development, there is an implication that it may not yet be stable. The people who do the code writing are called Developers, or Dev.

**Operations** *(Ops)* is a phase and a team we associate with building and maintaining the environment(s) used for running code from Development, as well as infrastructure used to support the running code. The people who run code may also be Developers, but they are also commonly known as Operators, Ops, SysAdmins, SREs, Production Engineers, and increasingly (and incorrectly) as DevOps Engineers.

**DevOps** is the art of joining principles from traditional software Development and Operations so both can work better together. DevOps is not a phase of development, nor is it a role, despite the emergence of DevOps engineering roles or teams. It is an organization’s professional culture, and emotional intelligence for working together as a single team. The purpose of DevOps is managing expected behavior of the product in production with respect to constant “change of state” (we’ll talk about that soon).

## The problem DevOps solves
An industry trope is the antagonistic rivalry about whose role, Dev or Ops, is more important. But it doesn’t need to be a battle. DevOps is a culture or method of interaction between Dev and Ops and a direct result is shortened feedback loops between writing code (development) and running code (operations). 

Admittedly, “DevOps” is a more complex concept when compared to Dev or Ops, which muddies an otherwise straightforward conversation because the actual tasks of practicing DevOps are not one-size-fits all.

Software is rarely a single moving piece. The benefit is the flexibility to incrementally change the state of any single piece. The “change of state” refers to updates to code or the supporting infrastructure, and effectively communicating those changes to the people involved. As a system grows in complexity, it takes some effort to make changes without disrupting other pieces.

DevOps, as a practice, is about managing the changes to those moving pieces in an organized and intentional manner. An example of where DevOps builds this bridge is deploying to production. Thin encourages releasing and running code in a way that Devs and Ops can anticipate each other’s changes, at a high rate. These procedures are preferably automated, for speed and consistency.

## Change the job title on your reqs: DevOps is not a role!
Unfortunately, DevOps is increasingly used as a catch-all for all engineering tasks that do not have an owner. The result is that it starts to lose any specific meaning.

A recent (and regrettable) trend in job postings is to rebrand SysAdmin or Operations roles into “DevOps engineer” roles. This makes it more difficult for companies and job-seekers alike to make a good match.

Case in point: coding is often listed as a requirement for a “DevOps Engineer” role, but if that role is actually an operations role, there will be few opportunities to write code. This means that new hires joining with the expectation that their role includes coding will feel misled, and turnover will be increased.

## What does a solution look like?
So what is DevOps if not a role? Let’s describe practicing DevOps through the actions of the members of the technical organization.

### DevOps-enabled Dev vs Pure Development
Unlike pure development, DevOps is primarily about improving processes and analytics capabilities to remove friction from developers’ workflows, outside of writing code. It is not about product functionality or quality of the product code. For example, Devs define the terms of success or failure of the behavior of their code in production. But thanks to DevOps practices, they can analyze that data to inform their next actions. 

Devs in a DevOps practice have a shorter onboarding process as well. Common tasks such as software requirements for build code and deploying code are documented through automation that is kept up to date. With this, new devs can focus on the codebase on day one, not spending all day reading documentation.

### DevOps-enabled Ops vs Pure Operations
Unlike pure operations, DevOps is proactive about observing how running code is behaving from within the code rather than only observing results. The purpose is to maximize the value of human time by only requiring a person to look into a problem if existing automated strategies fail to resolve it.

Additionally, the introduction of Continuous Integration/Continuous Delivery (or Deployment) pipeline (aka CI/CD) is an important collection of automation shared between Devs and Ops. The Devs know how to push code for build for the CI, and the Ops know how to pull build artifacts for deployment. 

### DevOps-enabled management
There is a lot to be said about DevOps-enabled management, but I will keep it brief (but stay tuned, this will be the topic of a future post). For now, I will be focusing on communication, quality of life of your employees, and a short aside on saving money on cloud operational expenditure.

As a product manager, DevOps directly serves the priorities and product roadmap, as they will be naturally driven from the analytics of your production environments. More objective discussion can be had with your developers and operators when you can provide more specific details and requirements to what is motivating your decision making as a manager. Data about feature usage or responsiveness can more easily be measured and placed onto a dashboard if the metrics to be tracked are known during development, rather than after a feature is complete. This production data can help facilitate discussions with your stakeholders.

As a hiring manager, DevOps enables you to be more specific about what it is you are looking for in job applicants. If you’re looking for a candidate with broad skills, you can justify why with actual functions that need served. Otherwise, you can also be much more specific with need for specialized roles since the functions of your direct reports feed into the quality of your analytics. 

Lastly, if you operate in cloud infrastructure such as AWS or Azure, your DevOps practice should condition you to analyze your compute usage for ways to save money. It can show you when you may be able to shut down compute resources for the night to save costs on guaranteed idle time that you would otherwise be paying for. Automation can automatically turn them back on for the work day if needed by devs, but otherwise, you may find that these resources are often unintentionally abandoned by devs.

## Conclusion
If you are a manager, how do you start a DevOps practice? You start by consistently being data-driven through requests for data from your employees. Show them how the data influences your decision making. The consistency of your requests ought to naturally lead to automation of data collection.

Remember that DevOps is more than operations. It is a professional workplace culture that starts with management through commitment to improve communication. 

To do both drive and support this, management must be very specific about what information they need from their product, then align their processes to reinforce these needs. Realize that this kind of organization of processes is optimal. The perceived constraints your employees experience provides very clear expectations for team success while allowing individual opportunity to be creative and fulfilled without setting expectations that it is any individual person’s responsibility.

DevOps is a practice that produces solutions that scale to the needs of the organization and humanizes the people who create solutions. It allows people to specialize their craft while providing a structure to let them trust that the rest of their surroundings (infrastructure) will be ready to accept any of their new creations.
