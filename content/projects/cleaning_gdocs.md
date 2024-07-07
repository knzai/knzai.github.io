+++
title = "Cleaning up web published Google Docs"
date = 2024-07-06
+++
As you probably know, Google Docs "Publish to Web" settings don't provide the cleanest html, much less the header it slaps on the top of all docs. While setting up this site I wanted to be able to import my resume from a GDoc where it lives for easy editing and .pdf export. Since I've been playing with Rust recently, I figured I'd use [Zola]https://www.getzola.org/, the Rust version of the Ruby based static site generator, [Jekyll](https://jekyllrb.com/), which is used for easily generating [Github Pages](https://pages.github.com/).

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
