---
layout: base
title: Animals
permalink: /animals/
---
<h1>Alpacas of {{ site.title }}</h1>

<table>
{% for animal in site.animals %}
        <tr>
          <td class="thumbnail">
            {% if animal.primary_image %}
              <a href="/animals/{{ animal.short_name }}">
                <img src="{{ site.url }}/media/{{ animal.primary_image }}"
                     alt="Picture of {{ animal.long_name }}"
                     class="thumbnail"
                     width="80" height="80">
              </a>
            {% endif %}
          </td>
          <td>
                <a href="/animals/{{ animal.short_name }}">
                {{ animal.long_name }} </a>
            <br>{{ animal.gender }}
            <br>{{ animal.short_description }}
          </td>
        </tr>

{% endfor %}
</table>
