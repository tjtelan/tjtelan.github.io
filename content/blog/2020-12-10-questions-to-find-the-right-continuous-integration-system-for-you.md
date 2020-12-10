+++
title = "Questions to Find the Right Continuous Integration System for You"
date = 2020-12-10
updated = 2020-12-10
draft = false 
description = "Questions to ask if you're considering switching CI systems"
[taxonomies]
tags = ["devops", "ci", "leadership"]
categories = ["devops"]
+++
Continuous integration is fancy shell scripting. It even uses shell scripting terminology like pipelines, but is obscured with marketing and many seemingly complex and different methods of configuration.

The purpose of this post is to discuss Continuous Integration (CI) Systems at a high level if you are considering switching to a new service. I want to introduce you to a few talking points that aren't discussed enough in order to help you make a decision.


## What are the goals of Continuous Integration (CI)?

The functions of continuous integration are very flexible and therefore, and the goals are super simple. Automatically run scripts upon the occurrence of an event.

Common events can be a git commit or a timer event set to run every 5 minutes.


## How does CI differ from shell scripting?

Continuous integration has a narrow context in which it is intended to run. It has extra structure in order to tell a tighter story. (The CI story leads into another story called Continuous Delivery/Deployment (CD), but we will only be focusing on CI)

A best practice of CI is to automatically build and/or run tests on every commit in order to validate whether the codebase builds/tests are complete without errors.

Basic structure defines conditions as well as commands or actions that should be executed when an event occurs. Conditions such as a new commit in a specific branch, or file paths. Or keywords in commit messages.

On the more advanced side, platform specific features like plugins may be introduced for sending or receiving events from other systems, initiating external triggers based on other pipelines, caching, cleaning up and notifications.


## What type of CI systems that exist today?

There is no shortage of software that is designed for Continuous Integration. What I believe sets these platforms apart from each other is:



*   The experience and effort involved with setting up a new environment for your organization
*   Path to configuring new pipelines, and maintaining them over time.

If your organization regularly exercises the creation of new environments, like in consulting orgs, it is reasonable to gain the experience with an open source tool that won’t cost you any money with licensing.

Otherwise, I might suggest picking a system the reduces the friction for pipeline creation and maintenance.

---

Styles of setting up new pipelines falls into two categories.


### Stateful (WebUI) pipeline config

Jenkins is the primary example of configuration via WebUI, as it is the functionality out of the box. Adding pipelines in this system requires a user to log into the WebUI, configure connections to builder systems and methodically define pipelines.


#### Pros 



*   The biggest player in this space, Jenkins, is free to install with flexible system requirements.
*   Relatively low skill required to get started. Setup of pipelines and any subsequent edits are performed through the browser with a few clicks.
*   Many plugins exist, which probably suit the needs of your org.
*   Most of the CI in this category are older and mature. Very search engine friendly solutions.


#### Cons



*   Administration is more difficult and time consuming to perform as footprint increases. Over time the details of the pipeline configuration may drift and be difficult to reproduce for the purposes of documentation or migration.
*   It is easy to neglect this kind of CI installation. Both a testament to stability, and a detriment to your org when unexpected outages occur. Rebuilding can be tedious and error prone.
*   Takes a lot of effort to secure natively in a cloud-based future. Typically these CI systems inconveniently end up hiding behind a VPN.


### Stateless (File-based) pipeline config

This is the modern style of CI system. Your TravisCI, Github Action, Azure DevOps

Typically we find this system is hosted through your git provider, or as a separate hosted service that we allow access to the repos. YAML is the most popular config format. 


#### Pros



*   Configuration of pipelines stay versioned alongside the codebases that use them.


#### Cons



*   No config schema standards, though. most use a yaml format.
*   Complexity becomes harder to manage, and requires a commit and push to repos in order to test. Testing contributes clutter in git logs, and uses up build minutes, which is the cost unit that many hosted services bill on.
*   Limited self-hosted options that are free.
*   Limited self-hosted options that have small system requirements


### My opinion

I strongly prefer the stateless type of configuration because it provides a more code-like arena where documentation can be provided.

Mixing the workflow of CI pipeline configuration with your organization’s version control practices can be disruptive if you need to push code in order to see the results of changes to your pipeline. It is a price to pay for the ability to easily correlate changes in codebase with changes in pipeline.

The balance to strike rests on your code hosting provider needs (i.e. costs per user) and the types of technologies and platforms you need to support for building (web, native, mobile, embedded, etc). This flexibility mostly skews support towards building for web-based technologies.

Also, Jenkins technically has file-based pipeline support via Jenkinsfile, but unless my org was already deeply invested in staying with Jenkins, I would steer clear. It is not the future. It is harder than necessary to use.


## What are the CI Hosting Options?


### Self-hosting

Self-hosting means running and maintaining a process on a physical or virtual machine that you have access to.


#### Pros



*   Somewhat more private for less effort if hosting in a private location.
*   Effective use of data center computers. Initial costs may be higher, but maintenance costs are typically lower.


#### Cons 



*   Being responsible for maintenance
*   Limited to the platforms that you have available.


### System as a Service (Hosted)

External systems as a service (Hosted services) allow users to just log in and connect their version control.


#### Pros



*   Not responsible for performing maintenance.
*   Typically authentication is provided, with options to support your org’s auth provider


#### Cons



*   Can be expensive if you require a lot of build time or resources
*   Shrinking caps on “free” resources for open source projects


## Issues to Consider when Switching between CI platforms

These are some categorized rhetorical questions that you or your organization should ask if you are migrating CI platforms


#### Threat model



*   Do you need to be deployed on-site? What are the upfront and ongoing costs associated?


#### Contributor model



*   How are contributors logging in?
*   What are the costs associated per seat?
*   Can


#### Maintenance



*   Who is responsible for the health of the pipeline?
*   How much time/money are you budgeting to spend on maintenance and improvements?


#### Cost of Build minutes



*   For open source projects, how many build minutes are being used?


#### Responsiveness needs



*   How many concurrent builds does your org require?


#### Technologies used



*   Containerizing builds is popular for isolation. But not all projects can build within a container.
*   Apple, Microsoft and embedded projects are not nearly as flexible and may require special considerations or resources.


#### Delivery/Deployment model



*   What do you need to happen after a build passes?
*   Are you creating a build artifact that needs to be stored somewhere?
*   What is the desired frequency between build vs delivery/deploy?


## Conclusion

Not all continuous integration is considered equal. But they all provide basically the same functions. In most cases, it is possible to self-host and do everything yourself. But sometimes it is worth paying money to a product / service that takes care of your needs. It is really all about making sure you know what the trade-offs are for your specific case.
