+++
title = "9 steps to rename your default Github branch safely"
date = 2020-09-30
updated = 2020-09-30
draft = false
description = "Checklist to migrate your git repository’s primary branch from master to main"
[taxonomies]
tags = ["git", "github", "github-actions", "migration", "checklist"]
categories = ["devops", "how-to"]
+++

Want to migrate your git branches from `master` to `main`? Your branch protections, in-progress PRs, and drafts can migrate safely. Follow this simple checklist to confidently make these changes and create a seamless experience for yourself and your developer community.

## Introduction
### What’s in a (branch) name? 

If you have existing git repos at Github (or any other git hosting platform), you probably have a branch in your repo named `master`. Starting October 1st, 2020, Github will officially stop their practice of naming the first branch of new repositories `master`. Instead, the name `main` will be used from now on. 

The usage of `master` is unfortunately deeply ingrained into those who learned how to use git and developed muscle memory. But did you know that Git (the tool) has no technical requirement that you use `master` as your default branch name? However, because it is the first branch created when you run `git init`, it’s often the default used. As a result, hosting platforms such as Github or continuous integration systems like Jenkins or TravisCI create workflows that typically use these defaults as release branches.

### Can’t I just rename `master` to `main`?

Automation and development workflows will make renaming `master` require more effort than just following [the first Stack Overflow answer you can find](https://stackoverflow.com/questions/6591213/how-do-i-rename-a-local-git-branch#6591218) to answer the question. 

In [Github’s official statement](https://github.com/github/renaming), they suggest waiting until later in the year to perform this switch yourself if your repo has any of the following conditions:

*   Open pull requests need to be retargeted to the new branch
*   Draft releases need to be retargeted to the new branch
*   Branch protection policies need to be transferred to the new branch

Don’t want to wait? While this won’t be as simple as just renaming your branches, you can still perform this switch on your personal or organization’s repos by modifying branch protections, PRs, and draft releases. Follow along to find out how.

## Migration strategy

I will walk through this migration, step-by-step. Feel free to skip the optional steps if they do not apply to your situation. Note that your new default branch name _does not_ have to be called `main` – this is just Github’s new default and what I will be using in this example (you can call your new branch `steve`, for all I care).

This guide is Github-focused, but you should still be able to follow along for other scenarios – these concepts are not exclusive to Github.

Here are the high-level steps we’ll go through:

1. Communicate upcoming changes to collaborators
2. Mirror/copy `master` branch to `main` branch
3. (Optional) Modify any CI that specifically triggers on `master` to use `main`
4. (Optional) Duplicate branch protections from `master`, and apply them to `main`.
5. (Optional) Modify draft releases to target `main`
6. (Optional) Modify open pull requests to retarget to `main`
7. Set the default branch to `main`
8. Delete `master` branch from local clone
9. Delete `master` branch in remote repo


## 1. Communicate upcoming changes to collaborators

**This is a very important step!**

If your codebase has a significant amount of active development and you plan to rename `master`, consider the subtle costs and impacts to the workflow. Other developers or operators will need to take action!

The name of a branch has no bearing on how git functions at a technical level. However, the name of a branch _can_ have high importance because of organizational norms of how development and operations are organized. Not communicating changes to your collaborators about renaming your default branch can cause unnecessary confusion when pushing code and loss of trust.

You can’t assume that everyone knows enough about git to make the necessary changes to their workflow to participate. (In which case, you can share this guide!)


## 2. Mirror/copy `master` branch to `main` branch

To start the migration, we want to branch off `master` into a local branch named `main` and push `main` to remote.

We’ll work from a fresh clone (assuming our default branch is `master`):

```bash
$ git clone <url>
$ cd <repo> 
```

In the new clone, we will create our new branch, `main`, and push it to Github.

```bash
$ git checkout -b main
Switched to a new branch 'main'

$ git push -u origin main
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
remote:
remote: Create a pull request for 'main' on GitHub by visiting:
remote:  	https://github.com/tjtelan/example-repo/pull/new/main
remote:
To github.com:tjtelan/example-repo.git
 * [new branch]  	main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-2.1.png", width=800) }}

With the new branch pushed, we can now start making the platform changes w/ respect to the `main` branch.


## 3. Modify any CI that specifically triggers on `master` to use `main`

_This step is optional. You can skip it if you don’t have any continuous integration (CI)._

CI is often triggered on events for specific branches. I’ll go over an example of updating CI workflow using Github Actions.


### Change your trigger branches

If your CI is triggered on events to your `master` branch, you’ll obviously need to change that to `main` for Actions to react to events on the `main` branch.

```yaml
[...]
on:
  push:
	branches: [ main ]
  pull_request:
	branches: [ main ]
[...]
```

Or within your jobs:

```yaml
[...]
jobs:
  build:
	runs-on: ubuntu-latest
	if: github.ref == 'refs/heads/main'
	steps:
[...]
```


### Update any plugins referencing `master`

For example, if you happen to be using any of Github’s official plugins, such as [actions/checkout](https://github.com/actions/checkout), 

Change your Github Actions to act on `main` instead of `master`

```yaml
	steps:
  	- name: 'Checkout'
    	uses: actions/checkout@main
```

(or use a tag instead of a branch)

```yaml
	steps:
  	- name: 'Checkout'
    	uses: actions/checkout@v2
```

If you’re using other plugins, you will need to check the repo of those plugins to verify if the author has migrated their `master` branch to `main`.

## 4. Duplicate branch protections from `master`, and apply them to `main`

_This step is optional if you don’t have any branch protection rules._

`https://github.com/<account>/<repo>/settings/branches`

You’ll need to create a new branch protection rule:

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-4.1.png", width=800) }}

You’ll probably need to have another window open with the `master` branch rules open so it’s easier to copy over… At least I did.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-4.2.png", width=800) }}

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-4.3.png", width=800, caption="Don't delete the master branch protection rules before you're ready to delete the branch altogeher") }}

After you’re done with all the branch migration, you can delete the branch protection rules for the `master` branch. There’s no urgency to do it immediately, but you will need to do this before completing the transition to `main` (Github won’t let you delete a branch that still has active protection rules.)

## 5. Modify draft releases to target `main`

_This step is optional if you don’t have any draft releases currently targeting `master`._

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-5.1.png", width=800) }}

In your repo Releases, select Edit on the draft:

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-5.2.png", width=800) }}


In the target dropdown, change the branch to `main` -- and then Save draft. That’s all there is to it!

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-5.3.png", width=800) }}

## 6. Modify open pull requests to retarget to `main`

_This step is optional. You can skip this step if you don’t have existing PRs targeting `master`._

So you have existing PRs against `master`?

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-6.1.png", width=800) }}

This is an easy fix! You can just edit the PR to use your new branch as the base branch.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-6.2.png", width=800) }}

And retarget the base branch to `main`

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-6.3.png", width=800) }}

And then confirm changing the base branch.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-6.4.png", width=800) }}

## 7. Set the default branch to `main`

Once you’ve got the `main` branch pushed up to Github, it is easy to set `main` to be the new default branch.

`https://github.com/<account>/<repo>/settings/branches`

In your repository settings, click the drop-down menu, and select `main`.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-7.1.png", width=800) }}

Click Update.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-7.2.png", width=800) }}

Click `I understand, update the default branch`

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-7.3.png", width=800) }}

If your organization needs more time to migrate away from `master`, you can pause after this step. Commits will need to flow into both `main` and `master` until it has been fully transitioned. This may be briefly inconvenient, but it will allow processes to continue until `master` can be deprecated.


## 8. Delete `master` branch in remote repo

You have two options to delete the master branch.


### Through the web browser

On the code tab, click the branch selection drop-down and click the `View all branches` link

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-8.1.png", width=800) }}

Note: If you had branch protection rules for `master`, you will need to delete them prior to this step. Otherwise Github will prevent the branch from being deleted.

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-8.2.png", width=800, caption="The master branch cannot be deleted because of its branch protection rules") }}

At the branch listing, find one of the rows with `master` listed, and click the trash icon on the right.

**Warning!** There is no additional prompt after clicking this icon. But you have the option to restore the branch while you are still on the page. However, if you’ve made it this far, deleting it is probably what you want

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-8.3.png", width=800, caption="Deleting the master branch protection rules") }}

{{ image(path="images/2020-09-28-github-rename-your-default-branch/step-8.4.png", width=800, caption="The master branch can now be deleted") }}

### Through the cli

```bash
$ git push --delete -u origin master
To github.com:tjtelan/example-repo.git
 - [deleted]     	master
```

## 9. Delete `master` branch from local clone

```bash
$ git branch -D master
```

![Spongebob](https://media.giphy.com/media/26u4lOMA8JKSnL9Uk/giphy.gif)

## Conclusion


### A branch by any other name would still merge as clean

The names of the branches don’t have any bearing on the functionality of git. But the practice of using offensive terminology to describe defaults or importance needs to end. Plus, `main` as an initial branch name is a better descriptive label for how the branch is conventionally used.

If you and your collaborators are able to cease the usage of `master` as your default branch without needing to rely on Github, your git host provider, or your operations team, I encourage you to do it.

The git project [will soon stop using `master`](https://sfconservancy.org/news/2020/jun/23/gitbranchname/) as the first branch created by `git init`. So your organization should prioritize this migration as well as making the necessary changes in your tooling and automation sooner rather than later.