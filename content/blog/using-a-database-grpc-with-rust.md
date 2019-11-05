+++
title = "Using a database + gRPC with Rust"
date = 2019-04-25
template = "page.html"
[taxonomies]
tags = ["rust", "how-to", "database", "diesel-rs", "grpc", "grpc-rs", "cli", "clap-rs"]
+++

This is a summary of my experience with writing a Rust DB-backed server/client with [grpc-rs](https://github.com/pingcap/grpc-rs) to communicate to the backend, and [Diesel](http://diesel.rs/) as an ORM to be used with [PostgreSQL](https://www.postgresql.org/).

## What did I want out of this exercise?
I don't consider myself an expert with Rust, also not a beginner. I've been following the Rust language development for a while. I also have been wanting to move from writing code for personal projects to writing for work projects. 

I have the privilege to choose the tools I want at work, but I must keep in mind that I don't work by myself. I need to be able to provide practical development advice and enough technical mentorship to my teammates to keep us all productive.

[Kevin Hoffman's blog post](https://medium.com/@KevinHoffman/streaming-grpc-with-rust-d978fece5ef6) let me know that what I wanted was possible today in stable (as opposed to nightly). Kevin's post is great, but I couldn't really absorb it my first few reads, because he is a more experienced Rust developer than myself. I didn't quite understand the code in his post, and I couldn't appreciate details he skimmed over which I will point out. I hope that I can provide supplemental details.

### My target
I am looking to build a very basic command line interface client, and a backend service. The cli communicates to the backend via gRPC, and the backend connects to a database.

**gRPC**

Based on Kevin Hoffman's experience, and the download activity on crates.io, I also used Pingcap's library [grpc-rs](https://github.com/pingcap/grpc-rs). However, while writing this post [tower-rs](https://github.com/tower-rs/tower-grpc) (which is a pure Rust implementation) is considered to be stable, though may not yet implement all features.

**Database**

For database, I decided to use [Diesel-rs](https://crates.io/crates/diesel) since there really aren't any other choices that I felt were better in a production environment. Diesel is a mature project that is very actively supported.

**Command line interface**

For the command line interface, I picked [clap-rs](https://crates.io/crates/clap), because I was interested in trying out defining the command line content and structure with yaml. In the future I would probably use [StructOpt](https://crates.io/crates/structopt). It happens to use clap-rs internally, but the written code is easier for me to read, and in my opinion, less code to write derives. For this reason, I'll probably gloss over the command line implementation. It provides the minimal amount of interaction I needed to highlight what appears to be an idiomatic pattern. 

After spending a few hours with all the tools, I wanted to jump in feet first with an example project.

## My first attempt figuring out my development pattern

I briefly considered not telling the parts of the story where I was figuring out how to get everything to compile but here it is. It ended up being a big learning experience. I won't get into super deep detail about my intentions since I ended up not going in this direction. But I will highlight what I learned.

I focused on individually building with Diesel and gRPC. Once I felt ready to do something productive with these crates, I started thinking about implementation by designing the protocol buffers first, and designing the database later. This ended up being a time-expensive mistake that hopefully will not need to repeated, dear Reader.

### Red flags in the workflow

I am generating my proto Rust code from `.proto` using [grpc-rs](https://github.com/pingcap/grpc-rs) in my [build.rs](https://github.com/tjtelan/rust-examples/blob/master/cli_grpc_diesel/workspace/protos/build.rs). It runs during `cargo build`. Based on Diesel's [getting started](http://diesel.rs/guides/getting-started/) guide, I expected that I would be annotating my proto Rust with the same `#[derive()]`. 

But If I'm going to be using the generated structs w/ Diesel, then I have to break up the protobuf compilation w/ some manual step to additionally add in the correct annotations, because the next `cargo build` regenerated code and removed my manual changes. This was a red flag, but I kept moving forward anyway...

Diesel also expects that your struct fields are 1:1 with your table schema for to use the custom  `#[Derive(Queryable)]` for querying the DB. If you haven't looked at `grpc-rs` generated grpc code, you'll see extra internally used struct fields: `unknown_fields` and `cached_size`. These are part of `grpc-rs`'s implementation of message serialization/deserialization. Moving forward could require representing these extra fields in the database, which has a bad smell and is wasteful of space. 

**Example of grpc-rs generated Rust code w/ the special fields**

```rust
#[derive(PartialEq,Clone,Default)]
pub struct OrderForm {
    // message fields
    pub quantity: i32,
    pub product: OilProductType,
    // special fields
    pub unknown_fields: ::protobuf::UnknownFields,
    pub cached_size: ::protobuf::CachedSize,
}
```

> Choosing to work directly with this generated struct means manually modifying the list of derive() and working around the special fields `unknown_fields` and `cached_size` so Diesel could still be used inserts and queries. Possibly requiring adding columns in the table schema. This is a more tight coupling than I want between my protobuf library and the data in the database.

### What I should have done

I only realized this after writing the client/server using the raw proto structs. I then moved onto designing the db schema and migrations. I got stuck trying to flow the grpc client calls to db inserts.

I concluded that I would need to create new structs that only Diesel would use since their support heavily relies on Derive code. It all felt like an impedance mismatch, and I was having to redo the same work over again without a clear path for where I was going.

This was a failure. If I could work backwards from the database inserts to the protos, then this might work out better for my understanding.

## My second approach

### Before implementation

I'm still learning how to write idiomatic Rust. When I got my protos compiling into generated Rust code, and assumed I needed to use it directly because it is native code, despite my unfamiliarity with all of the code generated by Pingcap's gRPC library.

> I'm relying heavily on the use of the Into trait to create a little anti-corruption layer so that the business logic on both my client and my server are not operating directly on the protobuf-generated structs. *-- Kevin Hoffman*

After a not-skimmed reading of [Kevin's Hoffman's post](https://medium.com/@KevinHoffman/streaming-grpc-with-rust-d978fece5ef6), I noticed he described using this same approach in a hand-wavey manner. I wasn't ready to appreciate the warning without some example code or a diagram.

#### Use separate structs for business logic 

I hadn't immediately considered that I might want to write my own structs instead of using the protobuf-generated structs since my mindset was that the generated code would be ergonomic enough to use code.

However, the strategy of using separate structs offers very easy to use conversions because of the `From` and `Into` traits. This would be easier for the maintainability and readability of my code because I can contain that conversion logic in away from my business logic.

I could convert them back and forth between the protobuf-generated forms and the diesel supported forms with `.into()`. How is this achieved?

More on this during implementation...

##### What is using this pattern like in the code? 

An example interaction would look like this

Inserts into the database - Client side:

    1. User input 
    2. Create Diesel struct + any data manipulation 
    3. Convert Diesel struct into Proto struct 
    4. Send Proto struct in gRPC call

Inserts into the database - Server side:

    1. Receive Proto struct
    2. Convert Proto struct into Diesel struct + Any data manipulation
    3. Insert into DB

#### The Last complicated detail : Rust custom types mapping to Postgres Enums

I want to use Rust enums and Postgres enums to carry my usage of types all the way to DB insert/query. The diesel schema generator doesn't handle custom postgres enums well, but we can manage the conversion by hand by using a few Diesel Derives: `SqlType`, `FromSql`, and `ToSql` . I might cover using custom postgres types with Diesel in another post. But for now, I am going to hand-wave this detail.

The [Diesel-rs custom types tests](https://github.com/diesel-rs/diesel/blob/v1.3.1/diesel_tests/tests/custom_types.rs) were very useful helping me figure it out.  

#### Organizing code into cargo workspaces

With some experience under my belt and a better understanding of where relative domains in the code should be separated by crate, I wanted to organize before writing new code. The first thing I did was separate the codebase into [workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html#creating-a-workspace).

Separating into different crates would let me organize the struct conversion code from complicating the readability of the business logic code. This will make it easier to reuse patterns between the client and server side through importing the crates.

### Implementation

#### Write database schema

Because I need some kind of story to write code against, I decided to write an oil ordering system (because proto-diesel can be described as oil (har har))

My postgres type `oil_product` has a [pie chart](https://en.wikipedia.org/wiki/Oil_refinery#/media/File:Usesofpetroleum.png) of oil derived products that I got from the [wiki page of Oil Refinery](https://en.wikipedia.org/wiki/Oil_refinery#Major_products)

That helped me with my first thing: I need my database schema - [schema.rs](https://github.com/tjtelan/rust-examples/blob/master/cli_grpc_diesel/workspace/models/schema.rs)

Then I could write my migrations:

* [up.sql](https://github.com/tjtelan/rust-examples/blob/master/cli_grpc_diesel/workspace/migrations/2019-03-18-213310_create_orders/up.sql)
* [down.sql](https://github.com/tjtelan/rust-examples/blob/master/cli_grpc_diesel/workspace/migrations/2019-03-18-213310_create_orders/down.sql)

#### Get inserts into DB working

Second is getting inserts into the db working on the backend - [Link to specific commit](https://github.com/tjtelan/rust-examples/commit/0e40e27529170b22f5419559ce8659f7a1a154f3#diff-149a61a7aa6246849298372d0b2f196e)

**backend.rs**

This is a simple call from the backend to an internal function that performs the DB insert. After opening a connection, I test create a hardcoded order.

```rust
[...]
let conn = client::establish_connection();
let new_order = client::create_order(&conn, 1, schema::OilProductEnum::DIESEL);
[...]
```

**create_order**

This insert only works once because the id is set to `1`. But the result is in insert of an order into the database, and returning the inserted `Order` from the function. 

```rust
pub fn create_order(conn : &PgConnection, quantity : i32, product_type : OilProductEnum) -> Order {
    let new_order = vec![
        Order {
            id : 1,
            quantity : quantity,
            product_type : product_type,
        },
    ];

    diesel::insert_into(orders::table)
        .values(&new_order)
        .get_result(conn)
        .expect("Error saving new order")
}
```

##### Creating user input structs for business logic

I created some structs solely for taking user input. It will converted to a proto form that will be used for gRPC calls

These structs didn't include dynamic info like ids or timestamps, since those are generated right before insert on the server side.

Separate proto messages needed to be defined specifically for taking user input from the client-side.

**One of the business logic structs**

```rust
pub struct OrderForm {
    pub quantity : i32,
    pub product_type : OilProductEnum,
}
```

**The corresponding proto message definition**

```protobuf
message OrderForm {
    int32 quantity = 2;
    OilProductType product = 3;
}
```

##### Converting business logic struct to/from proto-generated struct

I implemented the `From` trait to convert my custom type to protobuf types for the grpc client calls (and vice-versa). The [From](https://doc.rust-lang.org/std/convert/trait.From.html) trait gives us the [Into](https://doc.rust-lang.org/std/convert/trait.Into.html) implementation for free.

```rust
// Convert from the protos to our type
impl From<refinery::OrderForm> for OrderForm {
    fn from(proto_form : refinery::OrderForm) -> Self {
        OrderForm {
            quantity : proto_form.get_quantity(),
            product_type : OilProductEnum::from(proto_form.get_product()),
        }
    }
}

// Convert from our type to the proto
impl From<OrderForm> for refinery::OrderForm {
    fn from(rust_form : OrderForm) -> Self {
        let mut order = refinery::OrderForm::new();

        order.set_quantity(rust_form.quantity);
        order.set_product(refinery::OilProductType::from(rust_form.product_type));
        order
    }
}
```

Snippet from [convert.rs](https://github.com/tjtelan/rust-examples/blob/master/cli_grpc_diesel/workspace/models/convert.rs):


#### Take user input before making gRPC call

We want to take user input from a client, make a grpc backend call, then insert into the db from the backend.

We already have taken care of converting to and from proto forms, so this is focused on control flow now.

##### Move inserts into gRPC server endpoint

Insert will occur after calling into the grpc server endpoint from the client-side.

On the client-side, I created a protobuf-generated struct with default values, for demonstrating the gRPC call to the backend works. I can easily take user input afterwards.

##### Receive proto struct and convert into DB insertable struct

Lastly, I worked out taking in user input, and using it to instantiate one of my custom types. During the grpc backend call, I call .into() on my type, which will convert to the protobuf form. On the backend, I take in the request, and call `.into()` to convert back into my type so I can marshal into a diesel insert call.

**Server-side**

I'm converting the proto-form struct `req` into the business logic form `OrderForm` by calling `.into()`. Since the `create_order()` impl takes in `OrderForm`, there is no need to annotate the type with `.into()` and we're able to stay focused.


```rust
#[derive(Clone)]
struct RefineryService;

impl Refinery for RefineryService {
    // The client-side converts to refinery::OrderForm while calling this endpoint.
    // But we convert the proto type back to our custom type right before adding to the database
    fn order(&mut self, ctx: RpcContext, req: refinery::OrderForm, sink: UnarySink<refinery::OrderStatus>) {

    // Creating the return object
        let order_status = client::order_received_success();

        let f = sink
            .success(order_status.clone())
            .map(move |_| println!("Responded with status {{ {:?} }}", order_status))
            .map_err(move |err| eprintln!("Failed to reply: {:?}", err));

        let conn = client::establish_connection();
        // Convert the received proto request into our native type
        let _new_order = client::create_order(&conn, req.into());

        ctx.spawn(f)
    }
}
```

**Function for creating order**

We take the business logic form `order_form` and use it to create the insertable struct `new_order` with all of the column values for Diesel to execute.

```rust
pub fn create_order(conn : &PgConnection, order_form : OrderForm) -> Order {
    let timestamp = NaiveDateTime::from_timestamp(Utc::now().timestamp(),0);

    let new_order = vec![
        NewOrder {
            quantity : order_form.quantity,
            product_type : order_form.product_type,
            received_time : timestamp,
        },
    ];

    diesel::insert_into(orders::table)
        .values(&new_order)
        .get_result(conn)
        .expect("Error saving new order")
}
```

##### Do it again, in reverse, for queries

Last task to cover is repeating all of this work, but for making queries.

This ended up being slightly off pattern from implementing `From` traits, because I am returning a list of Orders, and the From trait apparently is not easily implemented for a Vec to the protobuf Rust equivilent. If I were planning on shipping this code somewhere other than for demonstration, I probably would spend more time implementing `From`. I ended up getting lazy, and wrapped the manual conversion in a function that loops and uses my already implemented From traits on the `Order` type. 

**user input side**

This client subcommand from the cli requests all of the orders from the database, then prints out the protobuf form as a demonstration. The next step would be converting the protobuf list into a Vec of some non-protobuf generated type.

```rust
if let Some(_matches) = matches.subcommand_matches("summary") {
    let empty_payload = protos::empty::Empty::new();

    // Send the gRPC message
    let orders = client.get_all_records(&empty_payload).expect("RPC Failed!");

    // Print all records from database
    println!("Order status: {:?}", orders);
}
```

**server endpoint**

The server takes in an empty proto type, so we don't have to do any type conversions. We then call a function `client::get_all_orders()` that calls Diesel to return all the data in a table. Then we make another function call `client::db_query_to_proto()` to convert our native data into a gRPC sendable form.

```rust
fn get_all_records(&mut self, ctx: RpcContext, _req: protos::empty::Empty, sink: UnarySink<refinery::OrderRecordList>){
    println!("Received request for all of the order records");
    let conn = client::establish_connection();

    // Call out to db
    let query_results = client::get_all_orders(&conn);

    // This conversion pattern is different than the plain `From` traits, because we
    // have to handle the outer vector in a special way, but I want to be lazy
    let parsed_query_proto = client::db_query_to_proto(query_results);
    //println!("Got results from the database: {:?}", query_results);

    let f = sink
        .success(parsed_query_proto.clone())
        .map(move |_| println!("Responded with list of records {{ {:?} }}", parsed_query_proto))
        .map_err(move |err| eprintln!("Failed to reply: {:?}", err));

    ctx.spawn(f)
}
```

**database query**

This function queries for everything in the orders table. There's nothing interesting here because Diesel handles everything. I just needed to annotate the type of vector that Diesel was going to return.

```rust
// get_all_orders is used by the backend
pub fn get_all_orders(conn : &PgConnection) -> Vec<Order> {
    let query : Vec<Order> = orders::table.select(orders::all_columns)
    .order_by(orders::id)
    .load(conn)
    .expect("Error getting all order records");
    query
}
```

**query to protobuf list**

You don't need to use all of the Rust features all up front or not use Rust at all. We can all hopefully appreciate that this can still be understood.

I briefly tried to implement `From` for `Vec<Order>`, but it became evident that it was going to take a little more effort than I was willing to spend at this moment. I'm first to admit that this is a bit of a hack, but that's fine for demonstration purposes. 

Protobuf's `repeated` keyword in the Rust code has its own type like `Vec<T>` called `RepeatedField` and we are simply looping through and creating a `Vec<refinery::OrderRecord>` so we could use the conversion impl `from_vec`. The rest is for building the return data.


```rust
// db_query_to_proto is used by the backend to convert a Vector of Order (from a Diesel select
// query) into the proto native OrderRecordList. Implementing `From` for a Vector would have taken
// longer, and used a wrapper type. That very well may be the more maintainable approach, but this
// was quicker

pub fn db_query_to_proto(rust_record : Vec<Order>) -> refinery::OrderRecordList {
    let mut proto_vec : Vec<refinery::OrderRecord> = Vec::new();

    // Let's take advantage of the `From` trait
    for r in rust_record {
        proto_vec.push(refinery::OrderRecord::from(r));
    }

    let proto_order = protobuf::RepeatedField::from_vec(proto_vec);

    let mut proto_final = refinery::OrderRecordList::new();
    proto_final.set_order(proto_order);
    proto_final
}
```

## In conclusion
Rust library support for gRPC is here. ORM support with Diesel-rs has been here for a while. But if you want to use gRPC and Diesel in the same project, maybe you can learn from my experience and be productive.

Do not primarily use the protobuf generated Rust types throughout your codebase. Especially if you plan on using Diesel-rs to deal with database inserts/queries, because structs need to be 1:1 with your table schema for the smoothest experience using Diesel-rs.

Implement the `From`/`Into` traits to more effectively convert between business logic structs and your protobuf generated Rust structs.

Convert to the proto Rust types only to send/return data over gRPC calls and then immediately convert back to your business logic type on the receiving end.

You don't need to write perfect Rust code in one go.

---

The code used throughout this post is located [here](https://github.com/tjtelan/rust-examples/tree/master/cli_grpc_diesel).
