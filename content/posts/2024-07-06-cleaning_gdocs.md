+++
title = "Cleaning Up Web Published Google Docs"
subtitle = "Parsing content with Rust regexs in Zola"
date = 2024-07-06
+++
As you probably know, Google Docs "Publish to Web" settings doesn't provide the cleanest html, not to mention the giant header it tacks on.

![image](/assets/images/posts/gdocs_header.png)

<!-- more --> 

While updating my resume and [working on some Rust projects](https://github.com/knzai), I decided I needed somewhere to publish both. Google Doc's built-in web publish isn't great on formatting, even without the header. And if you want it on your own site you have to embed it on your site somehow. If you use the "embeddded" url they give you for sticking in iframe it's a little better, but using iframe has plenty of downsides, such as less control over said formatting.

Since it's a chance to do some more rust, I decided to use [Zola](https://www.getzola.org/), the Rust version of the Ruby based static site generator, [Jekyll](https://jekyllrb.com/), which itself is used for easily generating [Github Pages](https://pages.github.com/). Using a static site generator means I could just [pull in the content](https://www.getzola.org/documentation/templates/overview/#load-data) of my GDoc resume at the time I run it and bam, web resume. Of course, even with that embedded url, it's still not great HTML (and if you just publish it raw, the javascript that tries to avoid this usage breaks your page)

This means I need to process the html somewhere between when google pubishes it and my final static site. I first played with a [service to cleanup the GDoc html](https://gdoc.pub/) but I needed additional reprocessing for my specific document (my resume) to look good. Then I considered setting up [that same code](https://github.com/augnustin/google-docs-publisher) as a one-off microservice to clean my doc and add some of my own tweaks. But the whole point of using a static site generator is you can just the resultant HTML somewhere and not have run an another service. So I started looking into what processing I could do of external content in Zola.

If I was working in with a ruby app, I'd just ~~hack~~ metaprogram/dynamically add in what I needed, but I'm working with Rust for this. So I checked out [filters the Tera templating engine](https://keats.github.io/tera/docs/#filters), the one used by Zola, provides, and didn't quite find what I needed. Then I noticed that [Zola actually adds in some additional filters](https://www.getzola.org/documentation/templates/overview/#regex-replace), including that glorious hammer for all string processing nails, [regex](https://en.wikipedia.org/wiki/Regular_expression).

Since I'm generating static content, I can just pull in the web published version of my resume at the time I publish, run it through some quick transforms, and viola: a slightly better web resume. Eventually I'll clean it up all the way, but it was surprisingly straight-forward to at least get the basics in place.  That is... straight-forward if you don't mind regular expressions in languages without native support for them. Zola uses the regex crate to add them to it's filter chain, and this doesn't give me all that much cleaner of a way to do this. But it works:

By wrapping the embedded html in a div with class=embed and prepending class that to all the styles I kept it stopped breaking all the rest of the site. And I could strip out scripts and a bunch of other filler styles.

Current approach:

```
{{ load_data(url=url) | 
regex_replace(pattern=`<head[\s\S]+?<\/head>`, rep=` `) | 
regex_replace(pattern=`<script[\s\S]+?<\/script>`, rep=` `) | 
replace(from="<!DOCTYPE html>", to="") | 
regex_replace(pattern=`ul\.[^}]+}`, rep=``) | 
regex_replace(pattern=`\.lst\-kix[^}]+}`, rep=``) | 
regex_replace(pattern=`(?<close>\})`, rep=`$close
.embed `) | 
regex_replace(pattern=`(?<close>>)(?<open><)`, rep=`$close
$open`) | safe }}
````
