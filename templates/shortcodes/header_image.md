{%- import "macros.html" as macros -%}
{%- set base_path = page.components | join(sep="/") -%}
{%- set path = macros::smart_img(path=base_path, default=config.extra.default_image) -%}
![{{page.description}}]({{path}} "{{page.title}}")


