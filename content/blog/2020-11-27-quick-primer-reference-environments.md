+++
title = "Quick Primer to Practical Reproducible builds: Reference Environments"
date = 2020-11-27
updated = 2020-11-27
draft = false 
description = "Make contributing easy. The system requirements to build your code is just as important as the code itself."
[taxonomies]
tags = ["devops", "automation", "scripting", "config-management", "virtual-machine", "containers"]
categories = ["devops"]
+++
## Overview

This post is inspired by a larger [Twitter thread by James Munns](https://twitter.com/bitshiftmask/status/1321623304004866050) about industry practices to follow for embedded systems projects that are not covered in school. Particularly the concept of a reference environment. However this idea is important across all platforms of software development. 

Our aim is to be pragmatic to a wide audience of “Developers” and not to be confused with the goals of the [reproducible builds project](https://reproducible-builds.org/). (I’m not worrying about achieving [complete build environment determinism](https://reproducible-builds.org/docs/deterministic-build-systems/). There is a lot more involved that is out of scope for this discussion, but I encourage others to check it out.)


## What’s the benefit?

The benefit of a reference environment is to allow a practical step-by-step plan for individuals to reproduce a suitable environment in order to build from a codebase, produce artifacts and interface with any external hardware.

I want to help you form a maintainable process of documenting what is needed to build your code, and create artifacts for release.

The expected outcome is to create a reference environment for build and release purposes.

An additional side-effect of this effort is a shortening of the effort to onboard new devs and testers into new projects or codebases. Additionally version control of this process will reduce your organization’s institutional knowledge.


### Your reference environment can be used for:



*   CI environments
*   Onboarding new developers
*   Projects that don’t get modified very often
*   Embedded projects
*   Mobile projects
*   Projects with private code
*   Projects with vendored / version pinned code
*   Legacy code


## Start your reference environment in steps


### First level: Automate what is easy and Document what is hard

You need to have a step-by-step set of commands to run that walk you through downloading and installing your tools in order to enable others to build their own reference environment. Tools and libraries installed through a package manager, and anything manually installed off a website.

The goal of documenting the setup of your local environment can then be further streamlined the more you automate the step-by-step into scripts that you can provide.

The experience you want to cultivate is a relatively short step from a fresh clone, to building and modifying code.

If you use a language that has its own package manager used to compile, such as Javascript’s NPM, Java’s Maven or Rust’s Cargo, then you are able to keep track of the names and version numbers of the libraries you use.

I recommend that you learn how to use these tools to also remove files created during build. Cached files from previous builds are classic causes of “[works on my machine](https://www.leadingagile.com/2017/03/works-on-my-machine/)” and may hide otherwise obvious issues. Make a habit of trying to reproduce issues starting from a cache-free build by using the same tools for build to also remove the files and directories it creates.

Not all language package managers come with cleanup functionality, so you may need to install  plugins. Otherwise you should use a tool like `make`, and create separate `make build` and `make clean` targets.


### Second level: Shell scripts 

Automation should be driven by makefiles or plain shell scripts like `bash`/`zsh`/`fish`/`sh` or in windows `batch` or `powershell`. The rationale is that these are plain commands that you can copy/paste from your terminal, and into the script. You can always call out to another language like `python`/`ruby`/`perl` or other tools.

But the initial point of functionality should be plain shell scripting through an executable shell script or a `Makefile`.

If you are working from an existing step-by-step document, then you should have a sequence of commands that you can transfer straight into your script. This is a lot fewer commands for your future users (and future you) to deal with.


### Third level: Configuration management

There are tools that specifically deal with configuration management of your operating system / development environment. One of their main selling points is declaring the desired state through config files instead of scripting everything step-by-step. The tools read the config files and check the system for differences. If differences are found, then these tools take specific actions in order to attempt to bring the reality of the system state to be the same as the config.

The config files lend themselves into achieving automation that is “[idempotent](https://en.wikipedia.org/wiki/Idempotence)”. A simple explanation of idempotency with respect to configuration automation is experienced when running the automation twice in succession. The first time, an automation tool takes a moment to execute because work is being performed. The second time, the tool discovers that there is no work to be done so the execution time is significantly reduced.

Examples:



*   Ansible
*   Saltstack
*   Puppet
*   Chef

In your shell scripts, you need to install these config management tools first. But then the tools can replace significant volumes of shell scripts in many cases because their idempotent properties lead to more efficient execution. The more popular tools have an added benefit of wide support of different OSes, allowing your configs to also widely support different OSes.


### Next level: Portable Reference Environments via Virtual Machines & Containers

Building your reference environment within a virtual machine may enable you to be a little less strict about documenting and automating your setup. After you build the environment, you can save a snapshot, back it up or even distribute it to others. This can be convenient and portable in most cases.

You can also use your scripts or config management to configure virtual machines, or containers. Using tools like [Vagrant](https://www.vagrantup.com/) or [Docker](https://www.docker.com/) allow you to store the instructions for building virtual machines (via [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile)) or containers (via [Dockerfile](https://docs.docker.com/engine/reference/builder/)) alongside your code. This enables potential contribution without the need of installing tools locally because the codebase includes a portable development environment.


#### Platform specific caveats

Virtualization or containerization is not an available option for every platform. In these cases, you may be limited to config management or documentation for your reference environments.

If your project has the following, you may have limited support for a portable reference environment. 



*   Apple products
*   Platform-specific tools like IDEs and/or compilers
*   Hardware requirements such as GPU
*   Very old “Legacy” OSes


## Conclusion

The specific tools, and libraries you use in development may seem obvious to you. But as a courtesy to an outsider, or even to yourself in the future, you need to provide requirements needed to build your code.

Documentation requires discipline to keep up-to-date. Scripts, config management or even a portable environment such as a virtual machine or a container are even better because they are easier to verify for correctness.

The less critically someone needs to think in order to get started, the easier it will be to focus on what matters. Reference environments are not one-size-fits all. They may be unique per project, or organization. Do future you or future team members a favor and write these details down. It can save a lot of time and avoid works-on-my-machine.