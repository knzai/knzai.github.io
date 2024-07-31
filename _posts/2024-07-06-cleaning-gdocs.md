---
layout: post
title: Cleaning Up Web Published Google Docs
image: /assets/img/posts/cleaning-gdocs.png
accent_image: 
  background: url('/assets/img/posts/jj-ying.jpg') center/cover
  overlay: false
accent_color: '#ccc'
theme_color: '#ccc'
description: >
  Parsing content with Rust regexes in Zola
invert_sidebar: true
category: rust
---

# Cleaning Up Web Published Google Docs

As you probably know, Google Docs "Publish to Web" settings doesn't provide the cleanest html, not to mention the giant header it tacks on.

* toc
{:toc}

While updating my resume and [working on some Rust projects](https://github.com/knzai), I decided I needed somewhere to publish both. Google Doc's built-in web publish doesn't do a perfect job on translating the formatting, even without considering the header. And if you want it on your own site you have to embed it on your site somehow. If you use the "embedded" url they give you for sticking in iframe it's a little better, but using iframe has plenty of downsides, such as less control over said formatting issues.

Since it's a chance to do some more rust, I decided to use [Zola](https://www.getzola.org/), the Rust version of the Ruby based static site generator, [Jekyll](https://jekyllrb.com/), which itself is used for easily generating [Github Pages](https://pages.github.com/). Using a static site generator means I could just [pull in the content](https://www.getzola.org/documentation/templates/overview/#load-data) of my GDoc resume at the time I run it and bam, web resume.

Of course, even with that embedded url, it's still not great HTML. And if you just publish it raw, the javascript that tries to avoid this usage breaks your page. Even if you find away around that the Google styles will clash with your site, and if you just strip those entirely, why bother keeping the content in a doc for editing.

This means I needed to process the html somewhere between when google publishes it and my final static site. I first played with a [service to cleanup the GDoc html](https://gdoc.pub/) but I needed additional reprocessing for my specific document (my resume) to look good. Then I considered setting up [that same code](https://github.com/augnustin/google-docs-publisher) as a one-off microservice to clean my doc and add some of my own tweaks. But the whole point of using a static site generator is you can just the resultant HTML somewhere and not have run an another service. So I started looking into what processing I could do of external content in Zola.

If I was working in with a ruby app, I'd just ~~hack~~ metaprogram in/dynamically add what I needed, but I'm working with Rust for this. So I checked out the [filters the Tera templating engine](https://keats.github.io/tera/docs/#filters), the one used by Zola, provides and didn't quite find what I needed. Then I noticed that [Zola actually adds in some additional filters](https://www.getzola.org/documentation/templates/overview/#regex-replace), including that glorious hammer for all string processing nails, [regex](https://en.wikipedia.org/wiki/Regular_expression).

As any polyglot programmer can attest, regular expression support across languages varies *heavily*. It's not even just the level of advanced features that are different, but the syntaxes for calling them vary and are famously abstruse. Rust doesn't have native regex support, but everyone seems to use [the same regex crate](https://crates.io/crates/regex) so even before I double-checked (I did, they do), I could assume that basic level of support.

Given the constraints of chaining regex filters without full programmability, no solution I came up with going to be pretty. But this works for the basics of stripping out unneeded styles, prefacing excessively broad selectors with `.doc-content` to not break other formatting, adding line-breaks for readability, etc. I even threw a class around the header content (everything before the first `<table>` in my case) that redundantly matches my site sidebar, so I could easily hide it with css for the screen view and show it for print view (since that just hides the whole sidebar). And heck, it's not like Rust doesn't start to look a little like line-noise once the type signatures get complicated enough, so a little regex shouldn't scare anyone:


```{% raw %}
{{ load_data(url=url) | 
regex_replace(pattern=`<head[\s\S]+?<\/head>`, rep=` `) | 
regex_replace(pattern=`<script[\s\S]+?<\/script>`, rep=` `) | 
replace(from="<!DOCTYPE html>", to="") | 
regex_replace(pattern=`ul\.[^}]+}`, rep=``) | 
regex_replace(pattern=`\.lst\-kix[^}]+}`, rep=``) | 
regex_replace(pattern=`(?<close>\})`, rep=`$close
.doc-content `) | 
regex_replace(pattern=`(?<close>>)(?<open><)`, rep=`$close
$open`) | 
regex_replace(pattern=`doc\-content">`, rep=`doc-content"><div class="gdoc-header">`) | 
regex_replace(pattern=`(<table)+?`, rep=`</div><table`) | 
regex_replace(pattern=`https://www.google.com/url\?q=(?<url>[^&]*)[^"]+`, rep=`$url`) |
regex_replace(pattern=`\s`, rep=` `) |
safe }}
{% endraw %}
```