+++
title = "What I learned running a live programming Twitch stream from Linux"
date = 2020-07-29
draft = false
[taxonomies]
tags = ["twitch", "streaming", "obs", "linux"]
categories = ["how-to"]
[extra]
summary = "Streaming a coding session on Twitch using a Linux laptop was easier than expected."
+++

I recently completed my first coding streaming session. A few people watched for a few minutes, so I considered it to be a success. I used what I already had on hand, did not spend any money and I was able to stream for about 3 hours from zero code to a small completed project. There is much room for improvement, but I want to share what I used to get started. 

My motivation for streaming my coding sessions is to improve my communication skills, as well as educate and demonstrate to others about being productive with programming languages and tech that I like using.

## My streaming setup

I’m running Linux on my [System76 Gazelle](https://system76.com/guides/gaze14/15b) laptop. My distro is Manjaro 20 (KDE Plasma).

The following are the hardware + software I already had

*   Laptop webcam
*   Condenser microphone (I use a Behringer C-1U)
*   Adjustable mic stand
*   External Monitor
*   External keyboard
*   External mouse
*   Streaming software (I used OBS. More on that later)
*   Text editor (I used VSCode)
*   Terminal (I used Alacritty + the built-in terminal in VSCode)
*   Web browser

{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/streaming-pov.png", width=480, caption="My extra basic streaming setup. Don't spend big money before you even have momentum.") }}

## Set accurate expectations for yourself and potential viewers

I watched a few coding streams from people that I see in the space regularly prior to running my own. I didn't want to reinvent the wheel, and so I had to experience what works for others and identify anything that is common. Pretty much *no one* is doing anything wholly unique, so I decided I would learn by copying what works for other coding streamers.

### Create loose structure to guide you

#### Write your title with intention

Unless you have an existing community, try to avoid low-value clickbait.

As a lowly unknown I need to bring a simple, but descriptive stream title. 

I want people to know:
* What language I'm writing in.
* What *fancy technology* I plan to use, if any.
* Succinct objective (Emphasis on **singular**!)

*Something to keep in mind*: Titles get truncated at about 40 or so characters. After that, viewers will have to put in some effort to mouse over your title to read past the cut.

> The title I settled on?
> 
> [Rust] GRPC Remote Command Line using Tonic + CLAP - Writing a blog post

#### Add a description and have a plan

Most of the streamers have some narrow theme for their time online in order to set expectations for people watching.

Explicitly let your viewers know what they are going to see in your description so they can decide if they will stick around. Otherwise you'll either get asked the same questions or people will just bounce out with disinterest.

> Specific to my first stream:
> 
> I wanted to dedicate time to writing the example Rust code for another blog post I have in progress.
> 
> With that in mind:
> 
> **Description**
> * Primary goal is to write a small CLI driven gRPC server/client in Rust
> * Secondary goal is to document my process including looking up documentation and testing.
> 
> **Plan**
> * In my notes, I broke down the domains of the application into ordered objectives I could follow.
> * I would take on each domain one at a time with the intention of connecting each of them together as each section became stable enough to test with user input.

#### Technical preparation

Since I didn’t want to worry about getting everything perfect I narrowed my focus on a few details and personal preferences about the stream.

*   Not streaming my entire desktop, instead individual windows.
    * (I thought this would be easier for viewers.)
*   Including a background for the negative space
*   Small on-screen banner that includes links to my other online platforms
    * Minor self-promotion
*   Microphone only, no external music
*   Webcam placement as close to level to or pointing down on my face
    * So people wouldn't have to look up my nose

I didn't worry about having chat visible but I did have it open for me to interact with just in case.

## Set up streaming software

Twitch has a list of [recommended software for broadcasting](https://help.twitch.tv/s/article/recommended-software-for-broadcasting?language=en_US). I ended up using Open Broadcaster Software, more commonly known as OBS because it has support for Linux.

{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/obs-logo.png", width=480, caption="Open Broadcaster Software a.k.a OBS") }}

I’m not going to go over the deep details of OBS, but I encourage looking for tutorials on Youtube. Even in 2020, the beginner OBS tutorials from a few years ago are still relevant and usable. They helped make using OBS a lot less intimidating.

Enable the preview and prepare to spend a little bit of time in OBS. What you see in the preview is what will get streamed out. Start simple. One Scene, and start with one source and add in sources as you get more familiar.

### Quick start guide to Sources

Here’s a short list of sources you may want to add from a Linux desktop into OBS and what they translate to to usable in OBS.

| Description of input | OBS source                                                   | Notes                                                                                                                |
|----------------------|--------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| Entire desktop       | Screen Capture (XSHM)                                        | If you have multiple monitors, you will need to select the screen you want to display                                |
| Specific window      | Window Capture (XComposite)                                  | You’ll need to select the window you want displayed. One source per window                                           |
| Image                | Image                                                        | Tested w/ JPEG, PNG                                                                                                  |
| Webcam               | Video Capture Device (V4L2)                                  | You’ll need to select your webcam from Devices if you have multiple cameras attached                                 |
| Capture Card         | Video Capture Device (V4L2)                                  | Similar to webcam, you’ll need to select your capture card device. Especially if you also have a webcam attached to your computer |
| Microphone           | - Audio Capture Device (ALSA)<br />- Audio Capture Input (PulseAudio) | It might be easier to configure audio through: Settings > Audio > Devices  Especially if you want to disable sources |
| Desktop audio        | - Audio Capture Device (ALSA)<br />- Audio Capture Input (PulseAudio) | (See notes for microphone)                                                                                           |

This may slightly differ from what the [official OBS Sources guide](https://obsproject.com/wiki/Sources-Guide) documents, but if you’re choosing to use Linux to stream then you probably already expect this. 

{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/obs-sources-linux.png", width=480, caption="What OBS sources look like in Linux") }}

The `Sources > Add` drop-down menu has icons that give good hints for what they do. Your results may vary, so be prepared to play around with settings. (But you already know that if you're insisting on using Linux...)

#### Workarounds for blacked out screens using laptop hybrid GPU setups

One issue I ran into while writing his guide was being unable to use a single window as a streaming source. Adding the source resulted in a window that was blacked out, but my mouse cursor was still visible when over the window.


{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/obs-hybrid-blackout.png", width=640, caption="VSCode's window is blacked out in OBS, but my cursor is still visible...") }}

To work around, you can pick one of the following solutions:

*   Force OBS and all your windows to run on the same GPU. Some software such as web browsers or IDEs use hardware acceleration by default. You can enable/disable accordingly to match OBS.
*   Or you can restart your laptop in either integrated or GPU mode (i.e., not hybrid mode)

The reason is due to how hybrid GPU works. OBS and the window I was trying to display were running on different gpus. 

For more information please read [this thread from the OBS Project forums](https://obsproject.com/forum/threads/laptop-black-screen-when-capturing-read-here-first.5965/).


### Configuring API keys for streaming

{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/obs-settings-stream-key.png", width=640, caption="OBS stream key settings") }}

The location for where you add in your service stream key is very easy to navigate to:

`Settings > Stream`

Select the service you want to stream to, and enter the Stream Key.

There are many preconfigured services in OBS, so you’ll probably only need to provide your stream key and not the service URL.

Common links to where you can get your stream key:

*   Youtube
    1. [https://www.youtube.com/live_dashboard](https://www.youtube.com/live_dashboard)
    2. `Stream name/key` is at the button of the page
*   Twitch
    1. [https://www.twitch.tv/settings/profile](https://www.twitch.tv/settings/profile) -- Then click `Channels and Videos`
    2. Or: [https://dashboard.twitch.tv/u/](https://dashboard.twitch.tv/u/)&lt;your-twitch-username>/settings/channel
    3. `Primary Stream Key` is listed at the top of the page

(I use a service called [Restream](https://restream.io/) which is supported by OBS. Restream will broadcast to multiple services at the same time. I use it to broadcast to YouTube and Twitch simultaneously.)

## Don’t overthink and start streaming

{{ image(path="images/2020-07-29-what-I-learned-running-a-live-programming-stream-from-linux/obs-start-streaming.png", width=480, caption="Don't worry about perfection. Just take the first step and start.") }}

The first thing I noticed after going live was that the platforms I was broadcasting to had some noticeable lag between my actions and seeing it live in the browser.

When you first get started, you probably won’t have a lot of people watching. This will be a good thing because you’re going to notice many details you’ll want to improve. 

I'm saying this to myself for the benefit of anyone else who got this far:

It will take time, effort and consistency on your part before you see results. So relax, try to have fun and enjoy the process.