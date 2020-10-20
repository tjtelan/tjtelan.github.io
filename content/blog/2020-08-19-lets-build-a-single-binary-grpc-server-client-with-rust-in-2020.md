+++
title = "Let’s build a single binary gRPC server-client with Rust in 2020"
date = 2020-08-19
updated = 2020-10-19
draft = false
description = "A detailed quick-start example for experienced devs using gRPC with Rust"
[taxonomies]
tags = ["rust", "grpc", "cli", "structopt", "tonic", "protobuf"]
categories = ["how-to"]
+++

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/rust_grpc_hero.png", width=640, alt="The Rust logo plus the gRPC logo") }}

There are plenty of resources for the basics of Rust and for protocol buffers + gRPC, so I don’t want to waste your time with heavy introductions. I want to bring you to action as soon as possible.

If you’re here I’ll make a few assumptions about you.


*   You can write code in another language, but you have an interest in Rust
*   You have basic familiarity with the command line for simple tasks (like listing files with `ls`)
*   You used web service APIs like REST, GraphQL or gRPC in code you’ve written
*   You’ve _skimmed_ through the [official protocol buffers (v3) docs](https://developers.google.com/protocol-buffers/docs/proto3) at least once
*   You are looking for some example code that you can copy/paste and modify


### Goals for the post

My goal is to walk through writing a small async Rust CLI application. It will take user input from a client, send it to a remote gRPC server, and return output to the client.

The finished code is available in my [rust-examples repo](https://github.com/tjtelan/rust-examples), as [cli-grpc-tonic-blocking](https://github.com/tjtelan/rust-examples/tree/master/cli-grpc-tonic-blocking). But I encourage you to follow along, as I will narrate changes while I make them.


### What are we writing?

In this example, I will be writing a remote command-line server/client.

The client will take in a command line command and send it to the server who will execute the command and send back the contents of standard out.

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/user_diagram_steps.png", width=640, caption="Diagram of the interaction we'll be working with", alt="Block diagram with our actors User, Client and Server. Data flows from user to client, then server before looping back.") }}

For simplicity sake, this example will wait for the execution to complete on the server side before returning output. In a future post I will demonstrate how to stream output back to a client.

I will show you how to:

1. Parse command line user input
2. Write protocol buffer message types and service interfaces
3. Compile protocol buffers into Rust code
4. Implement a gRPC client
5. Implement a gRPC server (non-streaming)
6. Use basic async/await patterns


#### Bigger picture goals

This is not just a simple Hello World.

I want to provide an example with a realistic application as a foundation. It has potential to be used for something useful, but keep in mind, this example is just a basic script runner and is not secure. 

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/multi_server.png", width=640, caption="This configuration is possible but out of scope", alt="A more complex diagram to illustrate how the user, client, server interaction scales. One user, one client, many servers.") }}

One could run multiple instances of this server on multiple hosts and use the client to run shell commands on each of them similar to continuous integration tools like jenkins, puppet, or ansible. (Hot take: CI is just fancy shell scripting anyway)

I do not recommend running this code as-is in any important environment. For demonstrative and educational purposes only!


## Writing the command line interface

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/bash_logo.png", width=200, alt="The Bourne again shell (BASH) logo") }}

The command line interface is the foundation that will allow us to package our gRPC server and client into the same binary. We’re going to start our new crate with the CLI first.

```shell
$ cargo new cli-grpc-tonic-blocking
    Created binary (application) `cli-grpc-tonic-blocking` package
$ cd cli-grpc-tonic-blocking
```

We will use a crate called [StructOpt](https://crates.io/crates/structopt). StructOpt utilizes the [Clap](https://crates.io/crates/clap) crate which is a powerful command line parser. But Clap can be a little complicated to use, so StructOpt additionally provides a lot of convenient functionality Rust a [#[derive] attribute](https://doc.rust-lang.org/reference/attributes/derive.html) so we don’t have to write as much code.


**cargo.toml**

```toml
[package]
name = "cli-grpc-tonic-blocking"
version = "0.1.0"
authors = ["T.J. Telan <t.telan@gmail.com>"]
edition = "2018

[dependencies]
# CLI
structopt = "0.3"
```

In order to bundle our client and server together, we will want to use our CLI to switch between running as a client or running as a server.


### Some UI design for the CLI

Note: While we are in development you can use `cargo run --` to run our cli binary, and any arguments after the `--` is passed as arguments to our binary


#### Starting the server

When we start our server, we want to pass in the subcommand `server`

```shell
$ cargo run -- server
```

##### Optional arguments for the server

Most of the time our server will listen to a default address and port, but we want to give the user the option to pick something different.

We will provide the option for the server listening address in a flag `--server-addr-listen`


#### Using the client

When the user runs a command from our client, we want to use the subcommand `run`. 

```shell
$ cargo run -- run
```


##### Required positional arguments for the client

Anything after the `subcommand run` will be the command we pass to the server to execute. A command has an executable name and optionally also arguments.

```shell
$ cargo run -- <executable> [args]
```

Or to illustrate with how one would use this command w/o cargo if it were named `remotecli`:

```shell
$ remotecli run <executable> [args]
```

##### Optional arguments for the client

Just like how our server will have a default listening address and port, our client will assume to connect to the default address. We just want to offer the user the option to connect to a different server.

We will provide the option for the server address in a flag `--server-addr`

### The CLI code so far

I’m going to break down the current `main.rs` into their structs, enums and functions to describe how StructOpt is utilized.

**Skip down to the next section [All together](#all-together) if you want to review this file in a single code block.**


#### In parts

##### ApplicationArguments

```rust
// This is the main arguments structure that we'll parse from
#[derive(StructOpt, Debug)]
#[structopt(name = "remotecli")]
struct ApplicationArguments {
   #[structopt(flatten)]
   pub subcommand: SubCommand,
}
```

* Like the comment says, this will be the main struct that you work with to parse args from the user input. 

* We use `derive(StructOpt)` on this struct to let the compiler know to generate the command line parser.

* The `structopt(name)` attribute is reflected in the generated CLI help. Rust will use this name instead of the name of the crate, which again is `cli-grpc-tonic-blocking`. It is purely cosmetic.

* The `structopt(flatten)` attribute is used on the `ApplicationArguments` struct field. The result effectively replaces this field with the contents of the `SubCommand` type, which we’ll get to next. 

If we didn’t use flatten, then the user would need to use the CLI like this:

```shell
## No subcommand flattening

$ remotecli subcommand <subcommand> … 
```

But with the flattening we get a simplified form without the `subcommand` literal.

```shell
## With subcommand flattening

$ remotecli <subcommand> ...
```

The reason for this pattern is to allow grouping of the subcommands into a type that we can pattern match on, which is nice for the developer. But at the same time we keep the CLI hierarchy minimal for the user.

##### SubCommand

```rust
// These are the only valid values for our subcommands
#[derive(Debug, StructOpt)]
pub enum SubCommand {
   /// Start the remote command gRPC server
   #[structopt(name = "server")]
   StartServer(ServerOptions),
   /// Send a remote command to the gRPC server
   #[structopt(setting = structopt::clap::AppSettings::TrailingVarArg)]
   Run(RemoteCommandOptions),
}
```

* We’re working with an enum this time. But again, the most important part is the `derive(StructOpt)` attribute.

* The reason to use an enum is to provide some development comfort. Each field in the enum takes in a struct where additional parsing occurs in the event that the subcommand is chosen. But this pattern enables us to not mix that up within this enum and make the code unfocused, and hard to read.

---

* The second most important detail is to notice the comments with 3 slashes `///`.

* These are [doc comments](https://doc.rust-lang.org/reference/comments.html#doc-comments), and their placement is intentional. Rust will use these comments in the generated help command. The 2 slash comments are notes just for you, the developer, and are not seen by the user.

---

* For the first subcommand, admittedly I named this field `StartServer` so I could show off using the `structopt(name)` attribute.

Without the attribute, the user would experience the subcommand transformed by default into the “kebab-case” form `start-command`. With the `name` defined on the StartServer field, we tell Rust that we want the user to use `server` instead.

(You can configure this behavior with the `structopt(rename_all)` attribute. I won’t be covering that. [Read more about rename_all in the docs](https://docs.rs/structopt/0.3.16/structopt/#specifying-argument-types))

---

The second subcommand `Run`... you’ll have to forgive my 👋hand waving👋.

* Remember that StructOpt is built on top of the [Clap](https://crates.io/crates/clap) crate.

* Clap is quite flexible, but I thought it was much harder to use. StructOpt offers the ability to pass configuration to Clap and we’re setting a configuration setting w/ respect to the parsing behavior for only this subcommand.

---

* We want to pass a full command from the client to the server. But we don’t necessarily know how long that command will be and we don’t want the full command to be parsed.

* The technical description for this kind of CLI parameter is a “Variable-length Argument” or a VarArg in this case. It is a hint for how to parse the last argument so you don’t need to define an end length -- it just trails off.

* We are configuring the `Run` subcommand to tell Rust that this uses a VarArg. See [the Clap docs](https://docs.rs/clap/2.33.1/clap/enum.AppSettings.html#variant.TrailingVarArg) for more info about this and other AppSettings.


##### ServerOptions


```rust
// These are the options used by the `server` subcommand
#[derive(Debug, StructOpt)]
pub struct ServerOptions {
   /// The address of the server that will run commands.
   #[structopt(long, default_value = "127.0.0.1:50051")]
   pub server_listen_addr: String,
}
```
* Our `server` subcommand has a single configurable option.

* The `structopt(long)` attribute specifies that this is an option that the user will specify with the double-hyphen pattern with the name of the option, which will be in kebab-case by default. Therefore the user would use this as `--server-listen-addr`.

* `structopt(default_value)` is hopefully self-explanatory enough. If the user doesn’t override, the default value will be used. The default value type is a string slice `&str`, but structopt is converting it into a `String` by default.


##### RemoteCommandOptions

```rust
// These are the options used by the `run` subcommand
#[derive(Debug, StructOpt)]
pub struct RemoteCommandOptions {
   /// The address of the server that will run commands.
   #[structopt(long = "server", default_value = "http://127.0.0.1:50051")]
   pub server_addr: String,
   /// The full command and arguments for the server to execute
   pub command: Vec<String>,
}
```

Our `run` subcommand has 2 possible arguments.

1. The first, `server_addr` is an optional `structopt(long)` argument with a default value that aligns with the `server` default.
2. The second `command` is a required positional argument. Notice how there is no `structopt` attribute. The resulting vector from the variable-length argument. The parser splits up spaces per word, and provides them in order within the Vec&lt;String>. (Matched quotes are interpreted as a single word in our situation). 


##### main()

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
   let args = ApplicationArguments::from_args();

   match args.subcommand {
       SubCommand::StartServer(opts) => {
           println!("Start the server on: {:?}", opts.server_listen_addr);
       }
       SubCommand::Run(rc_opts) => {
           println!("Run command: '{:?}'", rc_opts.command);
       }
   }

   Ok(())
}
```

Our `main()` is short and focused.

* Our return type is a `Result`. We return `()` when things are good, and returns a boxed [trait object](https://doc.rust-lang.org/reference/types/trait-object.html) that implements the `std::error::Error` trait as our error (the return trait object is boxed, because Rust doesn’t know how much space to allocate).

* We parse the user input using our StructOpt customized `ApplicationArguments` struct with `from_args()`. What’s great is invalid inputs are handled, and so we don’t need to spend any time straying from the happy path.

* After the parsing, we need to know what action to take next. We’ll either take a server action, or take a client action.

* We pattern match on our `SubCommand` struct, and [destructure the enum’s internal structs](https://doc.rust-lang.org/rust-by-example/flow_control/match/destructuring/destructure_enum.html) for the additional arguments.

* We eventually will call out to the respective server or client to pass along the args. However for now we call `println!()` to display the values.


#### All together

**main.rs**

```rust
use structopt::StructOpt;

// These are the options used by the `server` subcommand
#[derive(Debug, StructOpt)]
pub struct ServerOptions {
   /// The address of the server that will run commands.
   #[structopt(long, default_value = "127.0.0.1:50051")]
   pub server_listen_addr: String,
}

// These are the options used by the `run` subcommand
#[derive(Debug, StructOpt)]
pub struct RemoteCommandOptions {
   /// The address of the server that will run commands.
   #[structopt(long = "server", default_value = "http://127.0.0.1:50051")]
   pub server_addr: String,
   /// The full command and arguments for the server to execute
   pub command: Vec<String>,
}

// These are the only valid values for our subcommands
#[derive(Debug, StructOpt)]
pub enum SubCommand {
   /// Start the remote command gRPC server
   #[structopt(name = "server")]
   StartServer(ServerOptions),
   /// Send a remote command to the gRPC server
   #[structopt(setting = structopt::clap::AppSettings::TrailingVarArg)]
   Run(RemoteCommandOptions),
}

// This is the main arguments structure that we'll parse from
#[derive(StructOpt, Debug)]
#[structopt(name = "remotecli")]
struct ApplicationArguments {
   #[structopt(flatten)]
   pub subcommand: SubCommand,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
   let args = ApplicationArguments::from_args();

   match args.subcommand {
       SubCommand::StartServer(opts) => {
           println!("Start the server on: {:?}", opts.server_listen_addr);
       }
       SubCommand::Run(rc_opts) => {
           println!("Run command: '{:?}'", rc_opts.command);
       }
   }

   Ok(())
}
```

And that’s what we’ve done so far. This will be the full extent of the command line parsing functionality for this example, but we’ll revisit the `main()` function later.

If you’re following along, this code works with the `cargo.toml` provided at the top of this section. Play around using `cargo`.

For example try the following commands:

*   `cargo run --`
*   `cargo run -- server`
*   `cargo run -- server -h`
*   `cargo run -- run`
*   `cargo run -- run ls -al`
*   `cargo run -- run -h`
*   `cargo run -- blahblahblah`


## Protocol Buffers

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/protobuf_logo.png", width=480) }}

### What are Protocol Buffers?

[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/proto3) (protobufs) are a way to define a data schema for how your data is structured as well as how to define how programs interface with each other w/ respect to your data in a language-independent manner.

This is achieved by writing your data in the protobuf format and compiling it into a supported language of your choice as implemented as [gRPC](https://grpc.io/).

The result of the compilation generates a lot of boilerplate code.

Not just data structures with the same shape and naming conventions for your language’s native data types. But also generates the gRPC network code for the client that sends or the server that receives these generated data structures.

---

For what it’s worth, an added bonus are servers and clients having the possibility to be  implemented in different languages and inter-operate without issue due to. But we’re going to continue to work entirely in Rust for this example


### Where should protobuf live in the codebase?

Before jumping into the protobuf, I wanted to mention my practice for where to keep the file itself.

```shell
$ tree
.
├── Cargo.lock
├── Cargo.toml
├── proto
│   └── cli.proto
└── src
    └── main.rs
```

I like to keep the protobuf in a directory named `proto` typically at the same level as the `Cargo.toml` because as we’ll see soon, the build script will need to reference a path to the protobuf for compilation. The file name itself is arbitrary and [naming things is hard](https://www.karlton.org/2017/12/naming-things-hard/) so do your best to support your future self with meaningful names.


### The example protobuf

#### cli.proto

```proto
syntax = "proto3";

package remotecli;

// Command input
message CommandInput {
 string command = 1;
 repeated string args = 2;
}

// Command output
message CommandOutput {
 string output = 1;
}

// Service definition
service RemoteCLI {
 rpc Shell(CommandInput) returns (CommandOutput);
}
```

We start the file off by declaring the particular version of syntax we’re using. `proto3`.

---

* We need to provide a package name.

* The [proto3 docs](https://developers.google.com/protocol-buffers/docs/overview#packages) say this is optional, but our protobuf Rust code generator [Prost](https://crates.io/crates/prost) requires it to be defined for module namespacing and naming the resulting file.

---

* Defined are 2 data structures, called `message`s.

* The order of the fields are numbered and are important for identifying fields in the wire protocol when they are serialized/deserialized for gRPC communication.

* The numbers in the message must be unique and the best practice is to not change the numbers once in use. 

(For more details, read more about Field numbers [in the docs](https://developers.google.com/protocol-buffers/docs/proto3#assigning_field_numbers).)

---

* The `CommandInput` message has 2 `string` fields - one singular and the other `repeated`. 

* The main executable, which we refer to as `command` the first word of the user input.

* The rest of the user input is reserved for `args`.

* The separation is meant to provide structure for the way a command interpreter like Bash defines commands.

---

* The `CommandOutput` message doesn’t need quite as much structure. After a command is run, the Standard Output will be returned as a single block of text.

---

* Finally, we define a service `RemoteCLI` with a single endpoint `Shell`.

* `Shell` takes a `CommandInput` and returns a `CommandOutput`.


### Compile the protobuf into Rust code with Tonic

{{ image(path="images/2020-08-19-lets-build-a-single-binary-grpc-server-client-with-rust-in-2020/tonic-banner.png", width=640) }}

Now that we have a protobuf, how do we use it in our Rust program when we need to use the generated code?

Well, we need to configure the build to compile the protobuf into Rust first.

The way we accomplish that is by using a [build script](https://doc.rust-lang.org/stable/rust-by-example/cargo/build_scripts.html) (Surprise! Written in Rust) but is compiled and executed before the rest of the compilation occurs.

Cargo will run your build script if you have a file named `build.rs` in your project root.

```shell
$ tree
.
├── build.rs
├── Cargo.toml
├── proto
│   └── cli.proto
└── src
    └── main.rs
```


#### build.rs

```rust
fn main() {
   tonic_build::compile_protos("proto/cli.proto").unwrap();
}
```

The build script is just a small Rust program with a `main()` function.

We’re using `tonic_build` to compile our proto into Rust. We’ll see more `tonic` soon for the rest of our gRPC journey.

But for now we only need to add this crate into our `Cargo.toml` as a build dependency.

**Cargo.toml**

```toml
[package]
name = "cli-grpc-tonic-blocking"
version = "0.1.0"
authors = ["T.J. Telan <t.telan@gmail.com>"]
edition = "2018"

[dependencies]
# CLI
structopt = "0.3"

[build-dependencies]
# protobuf->Rust compiler
tonic-build = "0.3.0"
```

Build dependencies are listed under its own section `[build-dependencies]`.  If you didn’t know, your build scripts can only use crates listed in this section, and vice versa with the main package.

You can look at the resulting Rust code in your `target` directory when you `cargo build`.

You’ll have more than one directory with your package name plus extra generated characters due to build script output. So you may need to look through multiple directories.

```shell
$ tree target/debug/build/cli-grpc-tonic-blocking-aa0556a3d0cd89ff/
target/debug/build/cli-grpc-tonic-blocking-aa0556a3d0cd89ff/
├── invoked.timestamp
├── out
│   └── remotecli.rs
├── output
├── root-output
└── stderr
```

I’ll leave the contents of the generated code to those following along, since there’s a lot of it and the relevant info is either from the proto or will be covered in the server and client implementation.

This code will only generate once. Or unless you make changes to `build.rs`. So if you make changes to your proto and you want to regenerate code, you can force a code regen by using `touch`.

```shell
$ touch build.rs
$ cargo build
```

## Server

Moving onto writing our server now that we can use the protobuf generated code. We’re going to write the server (and client) in a new module.

```shell
$ tree
.
├── build.rs
├── Cargo.toml
├── proto
│   └── cli.proto
└── src
    ├── main.rs
    └── remotecli
        ├── mod.rs
        └── server.rs
```

### Cargo.toml

```toml
[package]
name = "cli-grpc-tonic-blocking"
version = "0.1.0"
authors = ["T.J. Telan <t.telan@gmail.com>"]
edition = "2018"

[dependencies]
# gRPC server/client
tonic = "0.3.0"
prost = "0.6"
# CLI
structopt = "0.3"
# Async runtime
tokio = { version = "0.2", features = ["full"] }

[build-dependencies]
# protobuf->Rust compiler
tonic-build = "0.3.0"
```

*This is the last change we’ll be making to Cargo.toml.*

We’re adding in `tonic` and `prost` as we implement the gRPC server/client. [Prost](https://crates.io/crates/prost) is the implementation of protocol buffers in Rust, and is needed to compile the generated code when we include it into the rest of the package.

[Tokio](https://tokio.rs/) is the async runtime we’re using. The gRPC server/client are `async` and we will need to adjust our `main()` to communicate more in the code that we’re now calling async functions..

### remotecli/mod.rs

```rust
pub mod server;
```

To keep the implementations organized, we’ll separate the server and client code further into their own modules. Starting with the server.

### remotecli/server.rs

Similar to the frontend CLI walkthrough, I’ll break this file up into pieces and review them.

**At the [bottom of this file’s section](#remotecli-server-rs-all-together) I’ll have the complete file there for copy/paste purposes.**

#### Imports

```rust
use tonic::{transport::Server, Request, Response, Status};

// Import the generated rust code into module
pub mod remotecli_proto {
   tonic::include_proto!("remotecli");
}

// Proto generated server traits
use remotecli_proto::remote_cli_server::{RemoteCli, RemoteCliServer};

// Proto message structs
use remotecli_proto::{CommandInput, CommandOutput};

// For the server listening address
use crate::ServerOptions;

// For executing commands
use std::process::{Command, Stdio};
```

* At the top of the file, we declare a module `remotecli_proto` that is intended to be scoped only in this file. The name `remotecli_proto` is arbitrary and for clarity purposes. 

* The `tonic::include_proto!()` macro effectively copy/pastes our protobuf translated Rust code (as per protobuf package name)  into the module.

---

* The naming conventions of the protobuf translation can be a little confusing at first, but it is all consistent.

* Our protobuf’s `RemoteCLI` service generates separate client and server modules using [snake case](https://en.wikipedia.org/wiki/Snake_case) + `_server` or `_client`. While generated trait definitions use [Pascal case](https://en.wikipedia.org/wiki/Camel_case) (a specific form of camel case with initial letter capitalized).

* From the server specific generated code, we are importing a trait `RemoteCli` which requires that we implement our gRPC endpoint `Shell` with the same function signature.

* Additionally we import `RemoteCliServer`, a generated server implementation that handles all the gRPC networking semantics but requires that we instantiate with a struct that implements the `RemoteCli` trait.

---

* The last import from the gRPC code are our protobuf messages `CommandInput` and `CommandOutput`

* From our frontend, we are importing the `ServerOptions` struct, since we are going to pass the user input in for the server listening address.

---

At last, we import from `std::process`. `Command` and `Stdio` - for executing commands and capturing output.

#### RemoteCli Trait implementation

```rust
#[derive(Default)]
pub struct Cli {}

#[tonic::async_trait]
impl RemoteCli for Cli {
   async fn shell(
       &self,
       request: Request<CommandInput>,
   ) -> Result<Response<CommandOutput>, Status> {
       let req_command = request.into_inner();
       let command = req_command.command;
       let args = req_command.args;

       println!("Running command: {:?} - args: {:?}", &command, &args);

       let process = Command::new(command)
           .args(args)
           .stdout(Stdio::piped())
           .spawn()
           .expect("failed to execute child process");

       let output = process
           .wait_with_output()
           .expect("failed to wait on child process");
       let output = output.stdout;

       Ok(Response::new(CommandOutput {
           output: String::from_utf8(output).unwrap(),
       }))
   }
}
```

* We declare our own struct `Cli` because we need to `impl RemoteCli`.

* Our generated code uses an `async` method. We add `#[tonic::async_trait]` to our trait impl so the server can use `async fn` on our method. We just have one method to define, `async fn shell()`.

---

* I’m 👋waving my hands👋 here for the function signature, but the way I initially learned how to write them was to go into the generated code, skimmed the code within the `remote_cli_server` module and modified the crate paths.

---

* The first thing we do when we enter `shell` is peel off the `tonic` wrapping from `request` with `.into_inner()`. We further separate the ownership of data into `command` and `args` vars.

* We build out `process` as the `std::process::Command` struct so we can spawn the user’s process and capture stdout.

* Then we wait for `process` to exit and collect the output with `.wait_with_output()`. We just want `stdout` so we further take ownership of just that handle.

---

* Last, we build a `tonic::Response`, converting the process stdout into a `String` while we instantiate our `CommandOutput`. Finally wrapping the `Response` in a `Result` and returning it to the client.

#### start_server

```rust
pub async fn start_server(opts: ServerOptions) -> Result<(), Box<dyn std::error::Error>> {
   let addr = opts.server_listen_addr.parse().unwrap();
   let cli_server = Cli::default();

   println!("RemoteCliServer listening on {}", addr);

   Server::builder()
       .add_service(RemoteCliServer::new(cli_server))
       .serve(addr)
       .await?;

   Ok(())
}
```

* This function will be used by the frontend for the purpose of starting the server.

---

* The listening address is passed in through `opts`. It’s passed in as a `String`, but the compiler figures out what type we mean when we call `.parse()` due to how we use it later.

---

* We instantiate `cli_server` with the `Cli` struct which we implemented as the protobuf trait `RemoteCli`. 

---

* `tonic::Server::builder()` creates our gRPC server instance.

* The `.add_service()` method takes `RemoteCliServer::new(cli_server)` to create a gRPC server with our generated endpoints via `RemoteCliServer` and our trait impl via `cli_server`.

* The `serve()` method takes in our parsed listening address, providing the hint the compiler needed to infer the required type and returns an `async Result<T> ` for us to `.await` on.

### main.rs - so far

We are making small changes to `main.rs` to plug in the server module. 

```rust
pub mod remotecli;

use structopt::StructOpt;

// These are the options used by the `server` subcommand
#[derive(Debug, StructOpt)]
pub struct ServerOptions {
   /// The address of the server that will run commands.
   #[structopt(long, default_value = "127.0.0.1:50051")]
   pub server_listen_addr: String,
}

// These are the options used by the `run` subcommand
#[derive(Debug, StructOpt)]
pub struct RemoteCommandOptions {
   /// The address of the server that will run commands.
   #[structopt(long = "server", default_value = "http://127.0.0.1:50051")]
   pub server_addr: String,
   /// The full command and arguments for the server to execute
   pub command: Vec<String>,
}

// These are the only valid values for our subcommands
#[derive(Debug, StructOpt)]
pub enum SubCommand {
   /// Start the remote command gRPC server
   #[structopt(name = "server")]
   StartServer(ServerOptions),
   /// Send a remote command to the gRPC server
   #[structopt(setting = structopt::clap::AppSettings::TrailingVarArg)]
   Run(RemoteCommandOptions),
}

// This is the main arguments structure that we'll parse from
#[derive(StructOpt, Debug)]
#[structopt(name = "remotecli")]
struct ApplicationArguments {
   #[structopt(flatten)]
   pub subcommand: SubCommand,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
   let args = ApplicationArguments::from_args();

   match args.subcommand {
       SubCommand::StartServer(opts) => {
           println!("Start the server on: {:?}", opts.server_listen_addr);
           remotecli::server::start_server(opts).await?;
       }
       SubCommand::Run(rc_opts) => {
           println!("Run command: '{:?}'", rc_opts.command);


       }
   }

   Ok(())
}
```

* We now import our `remotecli` module.

* The `main()` function changes slightly as well. First, we change the function to be `async`.

* We add the `#[tokio::main]` attribute to mark the async function for execution.

* And we call our new `start_server()` to actually start a server when the user runs the `server` subcommand.


### remotecli/server.rs all together

Here’s the final form of the server module.

```rust
use tonic::{transport::Server, Request, Response, Status};

// Import the generated rust code into module
pub mod remotecli_proto {
   tonic::include_proto!("remotecli");
}

// Proto generated server traits
use remotecli_proto::remote_cli_server::{RemoteCli, RemoteCliServer};

// Proto message structs
use remotecli_proto::{CommandInput, CommandOutput};

// For the server listening address
use crate::ServerOptions;

// For executing commands
use std::process::{Command, Stdio};

#[derive(Default)]
pub struct Cli {}

#[tonic::async_trait]
impl RemoteCli for Cli {
   async fn shell(
       &self,
       request: Request<CommandInput>,
   ) -> Result<Response<CommandOutput>, Status> {
       let req_command = request.into_inner();
       let command = req_command.command;
       let args = req_command.args;

       println!("Running command: {:?} - args: {:?}", &command, &args);

       let process = Command::new(command)
           .args(args)
           .stdout(Stdio::piped())
           .spawn()
           .expect("failed to execute child process");

       let output = process
           .wait_with_output()
           .expect("failed to wait on child process");
       let output = output.stdout;

       Ok(Response::new(CommandOutput {
           output: String::from_utf8(output).unwrap(),
       }))
   }
}

pub async fn start_server(opts: ServerOptions) -> Result<(), Box<dyn std::error::Error>> {
   let addr = opts.server_listen_addr.parse().unwrap();
   let cli_server = Cli::default();

   println!("RemoteCliServer listening on {}", addr);

   Server::builder()
       .add_service(RemoteCliServer::new(cli_server))
       .serve(addr)
       .await?;

   Ok(())
}
```

And that’s the server implementation and the frontend code for starting the server. It is a surprisingly small amount of code.

---

You can start an instance of the server by running:

```shell
$ cargo run -- server
[...]
Start the server on: "127.0.0.1:50051"
RemoteCliServer listening on 127.0.0.1:50051
```

## Client

We’re in the homestretch. Implementing a client. We’re going to create a new module within `remotecli` called `client.rs` that will follow the same patterns as we established for the server.

```shell
$ tree
.
├── build.rs
├── Cargo.toml
├── proto
│   └── cli.proto
└── src
    ├── main.rs
    └── remotecli
      	├── client.rs
        ├── mod.rs
        └── server.rs
```


### remotecli/mod.rs

```rust
pub mod client;
pub mod server;
```

We’re declaring the client module within `mod.rs` 


### remotecli/client.rs

Our client is a lot more straightforward. But splitting the module up into pieces for description purposes. 

**Again, full file is at [the end of the section](#remotecli-client-rs-all-together)**

#### Imports

```rust
pub mod remotecli_proto {
   tonic::include_proto!("remotecli");
}

// Proto generated client
use remotecli_proto::remote_cli_client::RemoteCliClient;

// Proto message structs
use remotecli_proto::CommandInput;

use crate::RemoteCommandOptions;
```

* Just like in our server, we create a module `remotecli_proto` and we use the `tonic::include_proto!()` macro to copy/paste our generated code into this module.

* We then include the generated `RemoteCliClient` to connect, and the `CommandInput` struct since that is what we send over to the server.

* Last include is the `RemoteCommandOptions` struct from the frontend so we can pass in the server address we want to connect to.


#### client_run

```rust
pub async fn client_run(rc_opts: RemoteCommandOptions) -> Result<(), Box<dyn std::error::Error>> {
   // Connect to server
   // Use server addr if given, otherwise use default
   let mut client = RemoteCliClient::connect(rc_opts.server_addr).await?;

   let request = tonic::Request::new(CommandInput {
       command: rc_opts.command[0].clone().into(),
       args: rc_opts.command[1..].to_vec(),
   });

   let response = client.shell(request).await?;

   println!("RESPONSE={:?}", response);

   Ok(())
}
```

* The helper function `client_run()` is an `async` function like our server. The frontend passes in a `RemoteCommandOptions` struct for the server address info as well as our raw user command.

---

* First thing we do is create `client` and connect to the server with `RemoteCliClient::connect` and do an `.await`.

---

* Then we build our request by creating a `tonic::Request` struct with our `CommandInput`.

* The user command is raw and needs to be sliced up to fit the shape of what the server expects. The first word of the user command is the shell command, and the rest are the arguments.

---

* Lastly we use `client` and call our endpoint with our request and `.await` for the execution to complete.

### main.rs

This is the final form of `main.rs`. The last thing we do to `main.rs` is plug in our `client_run()` function.

```rust
pub mod remotecli;

use structopt::StructOpt;

// These are the options used by the `server` subcommand
#[derive(Debug, StructOpt)]
pub struct ServerOptions {
   /// The address of the server that will run commands.
   #[structopt(long, default_value = "127.0.0.1:50051")]
   pub server_listen_addr: String,
}

// These are the options used by the `run` subcommand
#[derive(Debug, StructOpt)]
pub struct RemoteCommandOptions {
   /// The address of the server that will run commands.
   #[structopt(long = "server", default_value = "http://127.0.0.1:50051")]
   pub server_addr: String,
   /// The full command and arguments for the server to execute
   pub command: Vec<String>,
}

// These are the only valid values for our subcommands
#[derive(Debug, StructOpt)]
pub enum SubCommand {
   /// Start the remote command gRPC server
   #[structopt(name = "server")]
   StartServer(ServerOptions),
   /// Send a remote command to the gRPC server
   #[structopt(setting = structopt::clap::AppSettings::TrailingVarArg)]
   Run(RemoteCommandOptions),
}

// This is the main arguments structure that we'll parse from
#[derive(StructOpt, Debug)]
#[structopt(name = "remotecli")]
struct ApplicationArguments {
   #[structopt(flatten)]
   pub subcommand: SubCommand,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
   let args = ApplicationArguments::from_args();

   match args.subcommand {
       SubCommand::StartServer(opts) => {
           println!("Start the server on: {:?}", opts.server_listen_addr);
           remotecli::server::start_server(opts).await?;
       }
       SubCommand::Run(rc_opts) => {
           println!("Run command: '{:?}'", rc_opts.command);
           remotecli::client::client_run(rc_opts).await?;
       }
   }

   Ok(())
}
```

### remotecli/client.rs all together

```rust
pub mod remotecli_proto {
   tonic::include_proto!("remotecli");
}

// Proto generated client
use remotecli_proto::remote_cli_client::RemoteCliClient;

// Proto message structs
use remotecli_proto::CommandInput;

use crate::RemoteCommandOptions;

pub async fn client_run(rc_opts: RemoteCommandOptions) -> Result<(), Box<dyn std::error::Error>> {
   // Connect to server
   // Use server addr if given, otherwise use default
   let mut client = RemoteCliClient::connect(rc_opts.server_addr).await?;

   let request = tonic::Request::new(CommandInput {
       command: rc_opts.command[0].clone().into(),
       args: rc_opts.command[1..].to_vec(),
   });

   let response = client.shell(request).await?;

   println!("RESPONSE={:?}", response);

   Ok(())
}
```

### Final demonstration

To see this server-client end-to-end, we'll need two terminal windows open. In one, run the server, and in the other we'll run a simple `ls` command.

#### Server

```shell
$ cargo run -- server
[...]
Start the server on: "127.0.0.1:50051"
RemoteCliServer listening on 127.0.0.1:50051
```

#### Client

```shell
$ cargo run -- run ls
```

#### Output

```shell
Run command: '["ls"]'
RESPONSE=Response { metadata: MetadataMap { headers: {"content-type": "application/grpc", "date": "Wed, 19 Aug 2020 00:00:25 GMT", "grpc-status": "0"} }, message: CommandOutput { output: "build.rs\nCargo.toml\nproto\nsrc\n" } }
```

As we see, there is still work left to do in order to format the output in a more human readable way. But that is an exercise left to the reader.



## Conclusion

We just walked through building a CLI application that parses user input and uses gRPC to send a command from a gRPC client to the server for execution and return of command output.

Based on how we structured the frontend CLI using `StructOpt`, we allowed both the client and server to compile into a single binary. 

Protocol buffers (or protobufs) were used to define the interfaces of the server and the data structures that were used. The `Tonic` and `Prost` crates and Cargo build scripts were used to compile the protobufs into native async Rust code.

`Tokio` was our async runtime. We experienced how little code was necessary to support `async`/`await` patterns.

I hope that this walkthrough satisfies some curiosity about using gRPC for your backend code. As well as piqued your interest in writing some Rust code.