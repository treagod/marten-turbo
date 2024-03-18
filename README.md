<h1>
  <img src="./logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

## Tags

Marten Turbo introduces a new template tag `dom_id`, which supports the creation of turbo frame ids for Marten models

```html
{% for article in articles %}
  <div id="{% dom_id article%}"> <!-- Generates id artcle_1, artcle_2, etc. -->
    <!-- some content-->
  </div>
{% endfor %}

<form id="{% dom_id article%}" method="POST" action="/articles">
  <!-- Assuming the article instance is new an id of new_article is generated -->
</form>
```