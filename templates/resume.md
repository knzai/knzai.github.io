{% extends "base.html" %}

{% block extra_head %}
<link rel="stylesheet" href="{{ get_url(path="gdoc.css", trailing_slash=false) }}">
{% endblock content %}

{% block content %}
<div class="post embed">
{{ section.content | 
regex_replace(pattern=`doc\-content">(\n|.)+?<h1`, rep=`doc-content"><h1`) | safe }}
</div>
{% endblock content %}