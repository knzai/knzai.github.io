---
layout: welcome
sitemap: true
no_breadcrumbs: true
strip_headers: true
related_posts: false
---
<h2><a href="/about">About</a></h2>
<article>
	{% assign page = site.pages | where: "path", "about.md" | first %}
	{% assign text = site.data.strings.continue_reading | default:"Continue reading <!--post_title-->" %}
	{{ page.content | split: "<!--more-->" | first }}
	{% capture post_title %}<a class="heading flip-title" href="{{ page.url | relative_url }}">{{ page.title }}</a>{% endcapture %}
    <footer>
      <p class="read-more">
        {{ text | replace:"<!--post_title-->", post_title }}
      </p>
    </footer>
</article>

<h2><a href="/posts">{{ "Posts" }}</a></h2>
<!--posts-->
<h2><a href="/projects">{{ "Projects" }}</a></h2>
<!--projects-->