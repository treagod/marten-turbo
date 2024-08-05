<h1>
  <img src="./logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

[![GitHub Release](https://img.shields.io/github/v/release/treagod/marten-turbo?style=flat)](https://github.com/treagod/marten-turbo/releases)
[![Marten Turbo Specs](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml)
[![QA](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml)

Marten Turbo provides helpers to interact with Turbo applications using the <a href="https://martenframework.com/">Marten Framework</a>.

## Installation

Simply add the following entry to your project's `shard.yml`:

```yaml
dependencies:
  marten_turbo:
    github: treagod/marten-turbo
```

And run `shards install` afterward.

First, add the following requirement to your project's `src/project.cr` file:

```crystal
require "marten_turbo"
```

Afterwards you can use the template helper `dom_id` and the turbo handlers.

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

Marten Turbo also provides a turbo stream tag helper

```html
{% turbo_stream 'append' "articles" do %}
  <div class="{% dom_id article %}">
    {{ article.name }}
  </div>
{% end_turbo_stream %}

<!--
  <turbo-stream action="append" target="articles">
    <template>
      <div class="article_1">
        My First Article
      </div>
    </template>
  </turbo-stream>
-->

<!-- or in one line -->
{% turbo_stream 'append' "articles" template: "articles/article.html" %}
<!--
  <turbo-stream action="append" target="articles">
    <template>
      content of "articles/article.html"
    </template>
  </turbo-stream>
-->

<!-- dom_id is automatically applied if targeting a record -->
{% turbo_stream 'remove' article %}
<!--
  <turbo-stream action="remove" target="article_1">
  </turbo-stream>
-->
```


## Handlers

Marten Turbo provides an extension to the generic Marten handlers:

__Record Creation__: To create a record, use

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

__Record Update__: To update a record, use

```crystal
class ArticleUpdateHandler < MartenTurbo::Handlers::RecordUpdate
  model Article
  schema ArticleSchema
  template_name "articles/update.html"
  turbo_stream_name "articles/update.turbo_stream.html"
  success_route_name "articles"
end
```

__Record Deletion__: It's also possible to define a `turbo_stream` method

```crystal
class ArticleDeleteHandler < MartenTurbo::Handlers::RecordDelete
  model Article
  template_name "articles/delete.html"
  success_route_name "articles"

  def turbo_stream
    MartenTurbo::TurboStream.remove("article_1")
  end
end
```

## Turbo Native

Marten Turbo lets you check if a request is from a Turbo Native Application. To check, just check the `request.turbo_native_app?` variable.

A context producer also adds the `turbo_native?` variable to your templates to adjust your HTML. For the context producer you have to insert `MartenTurbo::Template::ContextProducer::TurboNative` <a href="https://martenframework.com/docs/templates/introduction#using-context-producers" target="_blank" rel="noopener noreferrer">into your context producer array</a>.

You could add a custom class to your body if a turbo native app hits your application:

```html
<body {% if turbo_native? %}class="turbo-native"{% endif %}>
  …
</body>
```
