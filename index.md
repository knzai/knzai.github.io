---
title: "About me"
layout: page
sitemap: true
---

![me](/assets/img/me.jpg){: width="200" style="float:right"}

The photo in the sidbar (pull the drawer out with your mouse for its full glory) is my mom performing a "wing-over" over the ski mountain in my home town. I grew up in the back of small planes, as my beloved, single, working, immigrant mom ran a glider business to support us, and often my "baby sitter" was just me being strapped into the backseat of the tow-plane, to promptly fall asleep. (She's since passed, hence the memorial photo).

As you might imagine, I was inculcated with a certain fearlessness from an early age, and was a competitive mogul skiier for 13 years, with ambitions of the Olympics. Those dreams never realized, most of my excitement nowadays comes from riding motorycles (my current beauty being a Triumph 1700 Thunderbird LT) with my club or solo, and the never-ending thrill of making tests turn green (or the Rust compiler build clean). I am not actually kidding, it's one of life's most dependable dopamine hits, even if not quite the same epinephrine spike.

To turn things more professional for a bit, I have over 20 years of experience in software engineering and management. I also have expertise in various high-compliance sectors such as fin/ed/health/gov tech and as well as in leading the development of high-throughput, low-latency, low-downtime systems. I particularly enjoy management of cross-functional teams and cross-team collabs.

As a queer trans woman, I strongly believe that diverse teams yield better results. In leadership roles, I strive to bring unique perspectives and prioritize creating a safe, communicative environment while also setting high team expectations. I believe in servant leadership and empowering my team to make the right decisions. I have a track record of addressing performance issues without resorting to punitive measures (a rare skill in tech), and I work hard to earn loyalty, which significantly improves team cohesion and retention.

As an engineer, I am a T-shaped polyglot: I have worked with almost every widely used web production language of the last 20 years and in particular have been working primarily with Ruby on Rails (and of course Javascript) for most of that time. My current other favorites include Rust (supplemented by bash and GitHub Actions) which I'm using for dealing with 80s game file formats: eventually I plan to rebuild an engine for Ultima 1-3. I'm also one of those weirdos who actually likes maintaining and improving other's code, infrastructure and CI/CD pipelines.

In addition to my professional background, I am an autodidact with a passion for learning, which began at a young age. I taught myself to read by age 2 1/2 from author read-along tapes of the [Serendipity books](https://en.wikipedia.org/wiki/Serendipity_(book_series)) - the backs of those planes was a lot more boring before yours can focus at the distance and realize the ground is that far away. And then I taught myself program at 8 years old (from [type-in programs](https://en.wikipedia.org/wiki/Type-in_program) from computing magazines).

In high school I hoped to save the world with nanotechnology (the 90s were an ambitious era), thanks [Eric K. Drexler](https://en.wikipedia.org/wiki/Engines_of_Creation) for the interesting tangent. My O-Chem course, an internship, and the described realities of actual chemical engineering work led me to return to computing. My diverse interests have led me on a unique journey that has contributed to my well-rounded perspective in both technology and beyond.


{% assign posts = site.posts %}
{% if posts.size > 0 %}
<aside class="other-projects related mb0" role="complementary">
  <h2><a href="/posts">{{ "Posts" }}</a></h2>
  <div class="columns">
    {% for post in posts limit:2 %}
      <div class="column column-1-2">
        {% if post %}
          {% include_cached pro/post-card.html post=post %}
        {% else %}
          Post with path <code>{{ post_path }}</code> not found.
        {% endif %}
      </div>
    {% endfor %}
  </div>
</aside>
{% endif %}

{% assign posts = site["projects"] %}
{% if posts.size > 0 %}
<aside class="other-projects related mb0" role="complementary">
  <h2><a href="/projects">{{ "Projects" }}</a></h2>
  <div class="columns">
    {% for post in posts limit:2 %}
      <div class="column column-1-2">
        {% if post %}
          {% include_cached pro/post-card.html post=post %}
        {% else %}
          Post with path <code>{{ post_path }}</code> not found.
        {% endif %}
      </div>
    {% endfor %}
  </div>
</aside>
{% endif %}
