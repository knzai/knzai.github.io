{%- import "macros.html" as macros -%}
{%- set base_path = page.components | join(sep="/") -%}
{%- set path = macros::header_image(path=base_path) -%}
{%- if path -%}
	![{{page.description}}]({{get_url(path=path)}} "{{page.title}}")
{%- endif -%}


