<h1>
  <img src="./logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

[![Marten Turbo Specs](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml)
[![QA](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml)

## Tags

Marten Turbo introduces a new template tag `dom_id`, which supports the creation of turbo frame ids for Marten models

```html
{% for article in articles %}
  <div id="{% dom_id article %}"> <!-- Generates id artcle_1, artcle_2, etc. -->
    <!-- some content-->
  </div>
{% endfor %}

<form id="{% dom_id article %}" method="POST" action="/articles">
  <!-- Assuming the article instance is new an id of new_article is generated -->
  <!-- Otherwise the id will be for example article_1 -->
</form>
```

Identifier will respect your namespace of the model. I.e. if you have an Article model in the app blogging the generated id will be `blogging_article_1`.


## Handlers

Marten Turbo provides an extension to the generic Marten handlers. For example to create a record the `MartenTurbo::Handlers::RecordCreate` is used:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

Notice how we use `MartenTurbo::Handlers::RecordCreate` instead of `Marten::Handlers::RecordCreate`.
Also the `#turbo_stream_name` class method gives you the option to define a turbo stream template which is
rendered instead of the normal template if a turbo request is made.
