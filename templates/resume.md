{% extends "base.html" %}

{% block extra_head %}
<link rel="stylesheet" href="{{ get_url(path="gdoc.css", trailing_slash=false) }}">
{% endblock content %}

{% block content %}
<div class="post embed">
{{ section.content | 
section.content | safe }}
</div>
{% endblock content %}