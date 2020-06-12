+++
title = "Building a Unix-shell in Rust - Part 4"
date = 2018-01-21
[taxonomies]
tags = ["rust"]
categories = ["how-to"]
[extra]
summary = "Exploring implementation of shell builtins"
+++
This is the 4th post in a running series about writing a simple unix shell in the Rust language. 
I suggest you catch up on the previous posts before reading ahead! 

* [part 1](@/blog/2017-11-05-building-a-unix-shell-in-rust-part-1.md)
* [part 2](@/blog/2017-11-26-building-a-unix-shell-in-rust-part-2.md)
* [part 3](@/blog/2017-12-31-building-a-unix-shell-in-rust-part-3.md)

---
Back to evaluating the parsed command. This time we are going to be implementing built-in functions.

### Shell builtins
Let’s quickly review how a shell works.
User is prompted for input. The input is tokenized (we are naively splitting on spaces). The first element of the tokenized input is the keyword, and the rest are the arguments. We execute the keyword with the arguments.

Our keywords correspond to either a shell function call (a builtin) or an external binary in your executable search path, which we will cover when we look to execute binaries in the next part. (In Bash, you can view this path by looking at the value of the environmental variable PATH. `$ echo ${PATH}`)

Builtin keywords are functions that are implemented in the shell codebase. Calls to builtin commands are just local function calls. 

In Bash, usually you can view what commands are implemented as shell functions with `$ man builtins`. (And some platforms use external binaries for many common builtins, rather than rely on the shell implementation)

Some common builtins, which we will implement are:
* echo
* history
* cd
* pwd

### My initial strategy
I’m going to keep my strategy simple. When I input a command, I want to run the builtin command. If my input is not a builtin, then let’s throw an error saying the command isn’t found. This will set us up for when we execute binaries,.

The first thing we want to do when we process the command is evaluate if it is a builtin. If it is, we want to pass arguments to the builtin function. 

I’m scratching my head a little bit about how to represent the mapping of a keyword to a function in an idiomatic way.

I’ve found the [HashMap](https://doc.rust-lang.org/std/collections/struct.HashMap.html) module, which is part of the standard collection library, but I’m looking to see if I can use something else that doesn’t require importing a library. I think what I want is an `enum` and I can pattern match to call builtin functions.

After a little bit of thought, I wondered if I could parse the string into the enum? My google-ing informs me that to accomplish this, I need to implement the [fromStr](https://doc.rust-lang.org/std/str/trait.FromStr.html) trait. 

```rust
enum Builtin {
  Echo,
  History,
  Cd,
  Pwd
}

impl FromStr for Builtin {
  type Err = ();
  fn from_str(s : &str) -> Result<Self, Self::Err> {
    match s {
      "echo" => Ok(Builtin::Echo),
      "history" => Ok(Builtin::History),
      "cd" => Ok(Builtin::Cd),
      "pwd" => Ok(Builtin::Pwd),
      _ => Err(()),
    }
  }
}
```

This is how I use the enum to call the function if it is a builtin

```rust
fn process_command(c : Command) -> i32 {
  match Builtin::from_str(&c.keyword) {
    Ok(Builtin::Echo) => builtin_echo(&c.args),
    Ok(Builtin::History) => builtin_history(&c.args),
    Ok(Builtin::Cd) => builtin_cd(&c.args),
    Ok(Builtin::Pwd) => builtin_pwd(&c.args),
    _ => {
        println!("{}: command not found", &c.keyword);
        1
    },
  }
}
```

Here’s an example of one of the builtins. (I’m only going to show one with functionality, because I’m going to implement the rest later)
I chose to implement echo because it is very easy to verify. 

```rust
fn builtin_echo(args : &Vec<String>) -> i32 {
  println!("{}", args.join(" "));
  0
}
```

The number I'm returning signal that the command is done executing and represent the exit code of the command. 0 is conventionally a successful call, and anything else is an error. 
And here we are in action:

```sh
$ cargo run
    Finished debug [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/rust-shell`
% echo test test test
DEBUG: Raw input: "echo test test test\n"
DEBUG: Split input: ["echo", "test", "test", "test"]
DEBUG: keyword : "echo"
DEBUG: args : ["test", "test", "test"]
test test test
DEBUG: Exit code : 0
% not_a_real_command lkfjdslf lkjfwe
DEBUG: Raw input: "not_a_real_command lkfjdslf lkjfwe\n"
DEBUG: Split input: ["not_a_real_command", "lkfjdslf", "lkjfwe"]
DEBUG: keyword : "not_a_real_command"
DEBUG: args : ["lkfjdslf", "lkjfwe"]
not_a_real_command: command not found
DEBUG: Exit code : 1
```

I think I’m going to use this break to do some minor cleanup, write tests, and start using the rust logging mechanisms, such as the [log](https://github.com/rust-lang-nursery/log) crate. I’ll be back in the next post for running executables.
