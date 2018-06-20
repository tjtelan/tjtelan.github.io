+++
title = "Building a Unix-shell in Rust - Part 1"
date = 2017-11-05
tags = ["rust", "how-to"]
+++
My goal is to find more work opportunities to write in Rust the same way I can write in Python and Go. Since I spend a lot of time designing and executing automation, it felt useful to start somewhere familiar. How about a simple Unix shell? Yes, I use bash all the time.

Rather than get this all worked out before posting, I'm going to document as much of my thought process in the design, as I have it. (But I am editing this to spare you the noisier stream-of-consciousness experience.)

I'll have code snippets occasionally, but I'm trying to keep the audience around intermediate experience (where I consider myself to be today). I'm going to assume you use another programming language today to Get Shit Done, and use the terminal to do simple things, but not necessarily write shell scripts.

Why am I doing this? I don't often see posts from beginning Rust learners doing practical, simple things (that can simply be copy/pasted and modified slightly), like in the other more mature language communities... Widest market? Probably not. 

I guess that's enough rambling. Let’s dive in.

---

## What’s a shell?
A shell is an interactive language interpreter that allows you to run text-based commands and translates them into an action, such as making internal function calls, or running external programs.

You usually use it to access resources from the operating system. 

Additional to accepting a text command - it typically outputs text results and/or causes some other side-effect.

You may know some of the name brand shells like the kind we're making, a Unix shell:
* Bourne-shell (sh)
* bash
* zsh
* fish

Or the windows specific:
* Command Prompt (cmd.exe)
* Powershell

Or interpreted languages:
* python 
* lua
* haskell 

Shells run in terminal emulators. This is (over-) simplified as the text-only window that runs your shell. 

It handles the interaction from you (known as Standard-In, like keystrokes) and your shell (known as Standard-Out for the buffered/flushed output style, and Standard-Error for the direct output style).

In most cases, the terminal emulator and shell are different processes (Windows’ cmd.exe and Powershell are confusingly, both the shell and terminal emulator) 

You may have made reference to it by other common names such as:
* command prompt
* terminal
* console

Examples of some terminal emulators
* xterm
* rxvt
* iTerm
* Terminal.app
* Windows Command Prompt
* Powershell

I’m going to focus on writing a bash-like shell. Functionality, and syntax should feel familiar. 

---

The shells are a [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop), a Read-Eval-Print-Loop.

Typically, a character (let’s say ‘$’) is printed and a cursor blinks. This informs the user that a command can be typed in.

You type in a command.

You hit enter to translate the command into an action.

The output of the program prints to the screen.
```sh
$ 
```
### What does this mean for me?
It lets us quickly stub the code out into this REPL  pattern 
Our main function that will enter a loop. Inside the main loop, we request a command from the user, and do something. Then we do it all over again. 

## Breaking down the steps
### First we Read
We need to take user input. Most shells print a symbol to signal to the user that we can input a command (as opposed to, for example, executing a command). I need to learn how to get a text command from the user. 

Let's start our definition of a command. 

**Command**
> a series of words separated by spaces.

```sh
$ keyword arg1 arg2 arg3… 
```

The first word is a keyword. It's either a built-in function or an executable on the filesystem, with the rest of the line being parameters passed to our function. 

**Keyword**
> One of 2 possibilities :
> * A built-in function to the shell (that is, calling a function in the code)
> * An executable
>   * Either in one of the directories in your PATH
>   * Or a filesystem path (relative or absolute)

### Then we Execute 
When we use a command that calls a built-in, we simply pass the arguments to the function, and return back to the start of the loop when it completes. 

#### And when we call an executable?
We need to make a [fork](https://en.m.wikipedia.org/wiki/Fork_(system_call)) syscall, that is, create a new process for the executable to run in, so it can have its own memory space, and manage its own interactions with the operating system. (The shell is still the parent process) 

To start a process inside the child process, we have to call the [exec](https://en.m.wikipedia.org/wiki/Exec_(system_call)) syscall. 

### Then we Process
This is when we cause side-effects to the system.

We want to provide feedback to the user to let them know the results of this process. To keep this simple, we will only consider returning text to the user, as we are providing commands as text. 

Our shell process has at least 3 file descriptors for passing input, or receiving output provided. Stdin, Stdout, and Stderr. I need to know how to do that purely with Rust. 

After the process is complete, any output should be printed to the screen, via stdout or stderr.

Exit codes will be treated as binary for this exercise. It should be set to 0 if we exit without error. Otherwise the exit code will be 1.

### Lastly, we Loop
Return of control will go back to the user. The default user prompt will print as a visual cue (along with the typical blinking cursor) and we should be able to enter another command. 

## The coding strategy 
So then we're running commands. Let's review the strategy. 

* I need to know how to take input command in a loop. 
* I need to process the input to separate the keyword from the arguments 
* I need a way to call both builtins and executables. 
* The most abstract : I need to give the user feedback about the command run. (E. g. Print onto screen as appropriate and set an exit code of the command.) 

In the next post, we'll dive into using `cargo` and  start writing in Rust. 
