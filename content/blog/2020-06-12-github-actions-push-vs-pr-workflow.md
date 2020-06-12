+++
title = "How to prevent Github Actions from deploying on Pull Requests when CI/CD"
date = 2020-06-12
draft = false 
[taxonomies]
tags = ["github", "github-actions", "ci", "cd"]
categories = ["how-to", "devops"]
[extra]
summary = "Walkthrough of an example Github Actions workflow that allows different steps for Push vs Pull Requests"
+++
## My experience using Github Actions for CI/CD as a solo contributor

I am using Github Actions to build and deploy my website when I push. That is a classic continuous integration / continuous deployment workflow. It’s convenient to commit, push and have my site build and deploy as a result. This workflow is simple but only works because I am the only contributor.

## Github Actions for CI/CD with Pull Request

It is a good practice to run sanity checks on pull requests prior to merging. How would that be accomplished with Github Actions?

It turns out that you can do this but you need to be very intentional with how your jobs are configured.

In my workflow, I am designating a main branch `zola` that will run full CI/CD. Build, test and deploy. And for any other branch, just build and test.

I’ll share my example Github Actions workflow file, then I’ll provide a template that you can modify and use for your own purposes.

## My example Github Actions workflow

Here’s my site’s current workflow file for Github Actions. I’ll break this down.
```yaml
on:
  push:
    branches:
      - zola
  pull_request:
jobs:
  build:
    runs-on: ubuntu-latest
    if: github.ref != 'refs/heads/zola'
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Build only'
        uses: tjtelan/zola-deploy-action@master
        env:
          BUILD_DIR: .
          TOKEN: ${{ secrets.TOKEN }}
          BUILD_ONLY: true
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/zola'
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Build and deploy'
        uses: tjtelan/zola-deploy-action@master
        env:
          PAGES_BRANCH: master
          BUILD_DIR: .
          TOKEN: ${{ secrets.TOKEN }}
```

At the top, I am specifying the events that I want to trigger on with the `on` top-level key.
```yaml
on:
  push:
    branches:
      - zola
  pull_request:
```
I want to trigger on push events to the `zola` branch, and all pull requests.

Later below are 2 jobs that are almost identical. I’ll break them down one at a time then compare their differences.

`build` job 
```yaml
  build:
    runs-on: ubuntu-latest
    if: github.ref != 'refs/heads/zola'
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Build only'
        uses: tjtelan/zola-deploy-action@master
        env:
          BUILD_DIR: .
          TOKEN: ${{ secrets.TOKEN }}
          BUILD_ONLY: true
```
1. This job uses the `ubuntu-latest` github hosted runner as my environment.
2. I do a check for the git ref via the `github.ref` key. Or another way to say this is I check that the working branch that triggered this job is not the `zola` branch. I’ll continue forward only if this condition is `true`.
3. Lastly are my steps. I use the `actions/checkout@master` marketplace action to check my code out, and I use my fork of an action for Zola called `tjtelan/zola-deploy-action@master`. I have an environment variable `BUILD_ONLY` set to `true` which results in building my site but not deploying it.


`build_and_deploy` job
```yaml
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/zola'
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
      - name: 'Build and deploy'
        uses: tjtelan/zola-deploy-action@master
        env:
          PAGES_BRANCH: master
          BUILD_DIR: .
          TOKEN: ${{ secrets.TOKEN }}
```
1. This job also uses the `ubuntu-latest` github hosted runner as my environment.
2. I do a similar check for the git ref via the `github.ref` key. This time I am looking for the working branch to be `zola`
3. Lastly are my steps. Same as the previous job, but I am configuring `tjtelan/zola-deploy-action@master` differently. Rather than setting `BUILD_ONLY`, I am defining `PAGES_BRANCH` to `master`, which is where I want to deploy my site code after build.

## Last words on job differences
The only differences are the branch check via `github.ref`, and the specifics of `steps`. I happen to be using my own Github Action `tjtelan/zola-deploy-action` but your steps could consist of anything you want to do differently between pull requests and push to your “special” branch.

## Github Actions template
```yaml
on:
  push:
    branches:
      - master
  pull_request:
jobs:
  build:
    runs-on: ubuntu-latest
    if: github.ref != 'refs/heads/master
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/master
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master
```
Here’s a template that you can use for your own push vs PR workflows. By default, I assume `master` as the special branch, so you’ll need to change that if you want to use a different branch. Additionally, you’ll need to provide all the steps to take after checking code out.

### Sources
* [Github Community question: How to trigger an action on push or pull request but not both?](https://github.community/t/how-to-trigger-an-action-on-push-or-pull-request-but-not-both/16662/3)
* [Github Actions reference: Events that trigger workflows](https://help.github.com/en/actions/reference/events-that-trigger-workflows) 
* [Github Actions reference: Virtual Environments for Github-hosted runners](https://help.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners)
* [Github Actions reference: Context and expression syntax - Github context](https://help.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#github-context)
