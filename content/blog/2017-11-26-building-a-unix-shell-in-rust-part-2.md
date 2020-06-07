+++
title = "Building a Unix-shell in Rust - Part 2"
date = 2017-11-26
[taxonomies]
tags = ["rust", "how-to"]
+++
This is the 2nd part of a series where I document writing a command shell in Rust. In the [previous post](@/blog/2017-11-05-building-a-unix-shell-in-rust-part-1.md) I reviewed what a shell is, and broke that down into stages I can use to organize my code.

### Getting user input
First thing we need to do is create a project. Let’s use Cargo to create this for us.

```sh
$ cargo new --bin rust-shell
```

For now, I'm going to assume we are only running interactively. So I'm just going to get a simple loop set up that asks for an input, and echoes it back to me.

```rust
use std::io;

fn main() {
  loop {
    let mut command = String::new();
    io::stdin().read_line(&mut command)
      .expect("Failed to read in command");
    println!("{0}", command);
  }
}
```

I’m using std::io to read input into the mutable command variable binding, then I println() to echo my input back to the screen.

Then we build:

```sh
$ cargo build
   Compiling rust-shell v0.1.0 (file:///Users/telant/src/rust-shell)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25 secs
```

No errors.

And testing it out:

```sh
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/rust-shell`
123
123

test
test
```

Great. Looks like that was easy.

What we see here is me trying 2 commands: `123` and `test`. We see the command printed right back. (Printing a short prompt might make that more obvious… ) 

### Parsing the input into tokens

Next step is to break the user input from a single continuous string into smaller pieces that we can evaluate. 

I am just going to tokenize the string using spaces as delimiters (because it is easy. It is, however, not always accurate, but, Dear Reader, I already know this is not the final way I am going to implement tokens. Splitting on spaces is too greedy of an approach. Quoted arguments are usually evaluated to be a single argument, including spaces, for uses that include passing entire raw strings to other programs. Let's not get perfection distract us. I'll stay focused on getting something that works...)

I actually ran into a little bit of trouble getting this working on a single line, with the original variable because of the type checker.

This did not work:

```sh
$ cargo build
   Compiling rust-shell v0.1.0 (file:///Users/telant/src/rust-shell)
error[E0282]: unable to infer enough type information about `B`
  --> src/main.rs:11:41
   |
11 |     println!("{:?}", command.split(' ').collect());
   |                                         ^^^^^^^ cannot infer type for `B`
   |
   = note: type annotations or generic parameter binding required
```

I’m lazy, and I didn’t look into how to explicitly reference the type.

This did work. 

```rust
let command_split : Vec<&str> = command.split(' ').collect();
println!("{:?}", command_split);
```

This is the relevant output

```sh
test test test
["test", "test", "test\n"]
```    

```sh
blah blah "string in quotes"
["blah", "blah", "\"string", "in", "quotes\"\n"]
```
I’m going to have to learn how type inference works in Rust sooner or later, but I’m not going to deal with it now. String types in Rust are kind of confusing coming from Python where I don’t have to deal with types very often.

(This is a warning from the future. You should lightly understand the idiomatic difference between String and &str. You find this out the hard way when you get to refactoring… see you in the future)

I’m going to use this moment to make the interface a more obvious when the we are ready to take user input by printing a prompt character.

```rust
use std::io::{self,Write};

fn main() {
  let prompt_char = "%";
  loop {
    print!("{0} ", prompt_char);
    io::stdout().flush().unwrap();

    let mut command = String::new();
    io::stdin().read_line(&mut command)
      .expect("Failed to read in command");
    println!("DEBUG: {:?}", command);

    let command_split : Vec<&str> = command.split(' ').collect();
    println!("DEBUG: {:?}", command_split);
  }
}
```

I added `DEBUG:` to our debug statements. Also I had to include a new `use`, use the `print!` macro, and flush the buffer so it would print to the screen immediately.

I got this pattern from the Rust docs for [print!](https://doc.rust-lang.org/1.4.0/std/macro.print!.html)


```sh
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.0 secs
     Running `target/debug/rust-shell`
% Feeling a little more shell-like now
DEBUG: "Feeling a little more shell-like now\n"
DEBUG: ["Feeling", "a", "little", "more", "shell-like", "now\n"]
%
```

### Classifying parsed input

Last thing I’m going to do is identify the keyword from the arguments, then I’ll do a little refactoring to help organize the new complexity. (I expect to do a little fighting with the borrow checker at this point.)

Getting the keyword is easy. I just need to pick off the first element of our tokenized command.

The arguments is a vector slice of everything but the first element of the command. Can I slice a vector as easily as slicing lists in Python? Yes.

```rust
use std::io::{self,Write};

fn main() {
  let prompt_char = "%";
  loop {
    print!("{0} ", prompt_char);
    io::stdout().flush().unwrap();

    let mut command = String::new();
    io::stdin().read_line(&mut command)
      .expect("Failed to read in command");
    println!("DEBUG: Raw input: {:?}", command);

    let command_split : Vec<&str> = command.split(' ').collect();
    println!("DEBUG: Split input: {:?}", command_split);

    let keyword = command_split[0];
    let arguments = &command_split[1..];

    println!("DEBUG: Keyword: {0}", keyword);
    println!("DEBUG: Number of arguments: {0:?}\nDEBUG: Arguments: {1:?}", arguments.len(), arguments);
  }
}
```

I have to call the slice by reference using `&` with the vector, and I specified the range I wanted to slice with the element I want to start from and `..` without an ending element. Rust figures out the bounds in this case.

### Time to refactor!

I’m going to make the main loop look a little more functional (inside the loop).

Printing the prompt? Easy. Function call.

```rust
fn print_prompt() {
  let prompt_char = "%";

  print!("{0} ", prompt_char);
  io::stdout().flush().unwrap();
}
```

Reading the command from user input? I had to look up how to return variables. The style is to use an implicit return, and no semicolon. You can use `return`, but it isn't very idiomatic. 

```rust
fn read_command() -> String {
    let mut command = String::new();
    io::stdin().read_line(&mut command)
      .expect("Failed to read in command");
    println!("DEBUG: Raw input: {:?}", command);

    command
}
```

Tokenizing the command? Gonna get a little more complicated. I’m going to set up a struct to represent the command so I can keep the tokenized command together in a single object.


---
### Optional : First fight with borrow checker 

I almost lost the motivation to continue the documenting my thought process because of this obstacle. This section can be skipped if you are looking to follow my happy path, and don't want to follow my confusion. 

(This is what I wrote first, when I was actually having a fight with the borrow checker…)

I have to learn a little bit about [lifetimes](https://doc.rust-lang.org/book/lifetimes.html) in order to get this to compile. This makes some sense, since the struct will need to own the slice data, and in the original code, we were just borrowing the slice.

I’m finding it confusing thinking about what I need to do in order to make the tokenizing function use the Command struct. If I can copy the args to the struct, and give ownership of the string to the struct, then I assume this will compile?

What type is the copied slice, and how do I specify that in the struct? How do I use the lifetime in code to find my use case? I don’t even know what other questions to ask next.

Rather than try to figure out how to compile, and get the struct working with tokenizing the command, I’ll try to play around in main() and try instantiating my struct.

What I need to be able to do is copy the data in the vector. I tried for a while trying to pass ownership of a slice, but I ended up finding a way to take the first element out of the vector, and having the rest be the arguments be what is left. I feel a little over my head at this point, and I’m going to spend some time reading the docs.

This is what the struct looked like.

```rust
/// Bad.
struct Command <'a> {
   keyword : String,
   arguments : &'a [&'a str],
 }
```

The reason I went with this approach was I thought I could pass the ownership of the heap from when I split the command by whitespace. This was really not a good approach, and I wasted quite a lot of time fighting with the borrow checker.

---

### Back to the show

I ended up changing the way I split the original command string so I would have a Vec<String> rather than Vec<&str>. Because String is owned and &str is borrowed, and the Command struct needs to own its data. 

I think I have a much more straightforward function.

```rust
struct Command {
  keyword : String,
  args : Vec<String>,
}

fn tokenize_command(c : String) -> Command {
  let mut command_split : Vec<String> = c.split_whitespace().map(|s| s.to_string()).collect();
  println!("DEBUG: Split input: {:?}", command_split);

  let command = Command {
    keyword : command_split.remove(0),
    args : command_split,
  };

  command
}
```

Before getting to the next step of evaluating the parsed command, I want to take a moment to learn how to set up tests that will run with the builds. See you next time. 
