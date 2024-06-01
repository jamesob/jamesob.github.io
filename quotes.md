---
layout: quotes
title: Quotes
---

<h1>quotes</h1>
<ul>

  {% for q in site.data.quotes %}
  <li>
    <p>
      {{ q.quote | markdownify }}
    </p>
    {% if q.author %}
    <p><i>{{ q.author | markdownify }}</i></p>
    {% endif %}
  </li>
  {% endfor %}

</ul>
