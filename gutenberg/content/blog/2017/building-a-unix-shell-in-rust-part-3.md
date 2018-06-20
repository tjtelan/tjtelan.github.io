+++
title = "Building a Unix-shell in Rust - Part 3"
date = 2017-12-31
tags = ["rust", "how-to"]
+++
This is the third post in a series on writing a simple shell in the Rust language. (I suggest you start from the [beginning](./blog/2017/building-a-unix-shell-in-rust-part-1.md)!) 

In the [previous post](./blog/2017/building-a-unix-shell-in-rust-part-2.md) , I implemented a simple REPL that simply prints out debug output with the input split by whitespace.

---
In this post, I would like to take the opportunity to set up tests before much more complex functionality gets included. Consider this to be the first part of what potentially might be multiple posts about writing and organizing testing with `cargo`.
### Is testing important?

> Program testing can be a very effective way to show the presence of bugs, but it is hopelessly inadequate for showing their absence. 
> [Edsger W. Dijkstra](https://en.wikiquote.org/wiki/Edsger_W._Dijkstra)

I don’t think it is controversial to say I think it is important. Good tests can help protect you from accidental regressions in functionality, and can be an added check on your assumptions, and manual testing. My intention is to write objective unit tests that will replace what I've been doing manually. 

### Why write the tests now? Why not later?
To be honest, I want the tests now because I’m looking for ways to use Rust for production code at work, and I need to get a feel for how a Rust codebase matures. As I am exploring Rust, I have come to be impressed with how easy `cargo test` makes it to write and execute tests.

It also will be less work to write test code for a small amount of code I just wrote now, rather than a larger amount of code later. Since it's been my experience that testing will just become reactive. And I get to go back to writing new feature code sooner.

### Getting started with unit testing
Testing is something that I always seem to go through with print statements, which is better than nothing, but not the most reliable way to be mindful of functionality regression. I would like to try to write more tests, as well as more functional code.

[https://doc.rust-lang.org/book/testing.html](https://doc.rust-lang.org/book/testing.html)

According to the official Rust handbook, for unit-style tests, like the what I would like to write, the convention is to create a `tests` module.

I’ll cover integration tests in a later post, when I reorganize the project into different files. For now, I’m going to start slow and try to understand the new parts of Rust I get to use.

In the same file as the rest of my code, I add my test module with unit tests. I’m going to cover testing the `tokenize_command()` function.

**main.rs**
```rust
#[cfg(test)]
mod unittest_tokenize_command {
    use super::*;

    #[test]
    #[ignore]
    fn empty_command() {
      assert_eq!("", tokenize_command("".to_string()).keyword)
    }

    #[test]
    fn test_keyword() {
      assert_eq!("test", tokenize_command("test".to_string()).keyword)
    }

    #[test]
    fn no_arg() {
      assert_eq!(0, tokenize_command("test".to_string()).args.len())
    }

    #[test]
    fn one_arg() {
      assert_eq!(1, tokenize_command("test one".to_string()).args.len())
    }

    #[test]
    fn multi_args() {
      assert_eq!(3, tokenize_command("test one two three".to_string()).args.len())
    }

    #[test]
    #[ignore]
    fn quotes() {
      assert_eq!(2, tokenize_command("test \”one two\” three".to_string()).args.len())
    }
}
```

### Breakdown of test module

I’ll introduce the new syntax.

#### use super::*
The use of `use` is new to me in Rust. I assume it means I am bringing in the namespace scope from outside to the top-level (instead of using `super::` at every function call) 

Since the test module is an inner module, we need to bring the functions from the outside scope into the module’s local scope. We can do this individually, but we can just use `*` to pull them all in, even though I’m not going to be testing them all right now.

For more information about this usage, look at the [Crates and Modules](https://doc.rust-lang.org/book/crates-and-modules.html#re-exporting-with-pub-use) page in the Rust documentation.

#### Attributes
The `#` lines are called [attributes](https://doc.rust-lang.org/book/attributes.html). Attributes are defined by the compiler, and are used for different things. As of Rust 1.17, we currently we cannot create our own attributes. I’ll quickly describe the attributes we use, (but here’s the [reference](https://doc.rust-lang.org/reference/attributes.html) to all of the attributes.

##### #[test]
The `#[test]` attribute labels the functions as tests to the rust compiler. This is how `cargo test` knows what functions to run for tests.

##### #[ignore]
The `#[ignore]` attribute tells cargo to skip the test. (However, you can tell cargo to run the ignored tests by running `cargo test -- --ignored`) I am using this attribute, because as I started writing tests, I realized I hadn’t covered the functionality that would let the tests pass. I don’t want to forget to do this, so I’ll write the test now.

##### #[cfg(test)]
In `#[cfg(test)]`, we’re using the `cfg` attribute on the `unittest_tokenize_command` module. In our usage, the attribute tells the Rust compiler to compile the module only when we are compiling tests, like when we run `cargo test`.

### Running the tests
We just need to run `cargo test`.

```sh
$ cargo test
   Compiling rust-shell v0.1.0 (file:///Users/telant/src/rust-shell)
    Finished debug [unoptimized + debuginfo] target(s) in 0.45 secs
     Running target/debug/deps/rust_shell-cdb27ec22ae15a63

running 6 tests
test unittest_tokenize_command::empty_command ... ignored
test unittest_tokenize_command::quotes ... ignored
test unittest_tokenize_command::no_arg ... ok
test unittest_tokenize_command::multi_args ... ok
test unittest_tokenize_command::test_keyword ... ok
test unittest_tokenize_command::one_arg ... ok

test result: ok. 4 passed; 0 failed; 2 ignored; 0 measured
```

And we see that the all but our ignored tests pass, which is good enough for now!

In the next post, I’ll be covering evaluating built-in keywords.
