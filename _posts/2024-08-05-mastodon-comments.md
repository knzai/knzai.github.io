---
layout: post
title: Easy-peasy comments on a static site - without needing another service
description: >
  If you are already using Mastodon to share your content, why not use it as the hub of discussion for your content
toot_id: 112908376346336974
---
Since I'm running a statically generated site via Jekyll, adding comments takes some addition thought. The last time I was looking into this Disqus was starting to take off, but using a third party service for something like this never quite sat right (and some privacy issues they went through later proved that out).

## The problem
Since I'm just hosting this on GH Pages, I started wondering about what'd it take to just have the comments live in the repos Issue (or better Discussions). The most popular ways of doing this seem to be [Utterances](https://github.com/utterance/utterances) and [Giscus](https://github.com/giscus/giscus), respectively. But either still requires a server or service, since fetching the comments from Github requires auth, and your unauthed readers aren't neccessarily going to sign in just to see wether there are comments.

* toc
{:toc}


## The solution
Then I realized, coupling the comments to the service that just happens to be where my site lives doesn't make sense (but it might for projects that live on GH with their sites also here). If they are comments, on my content, they should be managed similarly to how I'm managing, publishing, aggregating, etc my own content, which circled me around to social media and inevitably [the Fediverse](https://en.wikipedia.org/wiki/Fediverse). Of course, someone already made a [tool for that](https://github.com/dpecos/mastodon-comments).

It was trivially easy to drop in and now, any post I want comments on I just drop a toot_id into the front-matter of my post. This does mean the flow is slightly altered to "Write a private toot, publish content, set toot to public" but that just points out that if a social media post is the central organizing point of content, it should be the central organizing point.

## Caveats
1. Comments are purly client-side; this has no graceful degradation or progressive enchancement at all, which I'm usually opposed to: If I were expecting a masssive amount of comments, that should be part of search and archiving/history, it'd be an issue. But it shouldn't *that* bad to grab any comments on publish (I use a GH Action to do [grab my resume PDF anyway](/posts/2024-07-09-gdoc-pdf-export) so have easy place to tack on stuff like this) and then on the client-side only add the comments that don't already exist.
2. This technically does require a service/server: Yes, one I'm already using for sharing the self-same content. I'm becoming more of a believer in the Fediverse the more I use Mastodon, and it makes sense to centralize (hah!) there where I have some control over my content. I picked an instance I liked, and I could make my own instance, if I cared too.
3. No moderation: this goes partially hand-in-hand with the previous point. As currently implemented it depends on the moderation of the instance I chose. So far spam bots trying to sign-up to a Mastodon instance that requires admin verification, just to try and comment a low volume dev blog aren't a major concern. If at some point I wanted to insert my own moderation I could only show the comments that I have liked. Easy-peasy.
4. The original toot doesn't show up to kick-off discussion. I may need to tweak the script a bit further. I already grabbed it locally so I could adjust it to fit into my site better, so that's easy enough.
