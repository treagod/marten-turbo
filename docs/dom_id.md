# DOM IDs

Turbo needs stable IDs to know which element to swap. The `dom_id` tag builds them from a record:

```html
<article id="{% dom_id article %}">
  <h2>{{ article.title }}</h2>
</article>
```

A saved record gives you `article_1`, `article_2` and so on. A record that hasn't been saved yet
gives you `new_article`, which is handy for form wrappers:

```html
<form id="{% dom_id article %}" method="post" action="/articles">
  ...
</form>
```

`dom_id` respects the namespace of your model. An `Article` model in a `Blogging` namespace
produces `blogging_article_1`.

## Prefixes

The second argument prefixes the identifier. Useful when the same record shows up more than once
on a page:

```html
<article id="{% dom_id article %}">...</article>
<form id="{% dom_id article "edit" %}">...</form>
```

The form ends up as `edit_article_1`.

## From Crystal

Handlers that include `MartenTurbo::Handlers::Concerns::Streamable` can call `dom_id` directly.
That covers the [Turbo handlers](handlers.md), so a delete handler can build its stream without
hardcoding IDs:

```crystal
class ArticleDeleteHandler < MartenTurbo::Handlers::RecordDelete
  model Article
  template_name "articles/delete.html"
  success_route_name "articles"

  def turbo_stream
    MartenTurbo::TurboStream.remove(dom_id(record))
  end
end
```

`MartenTurbo::TurboStream` resolves records itself, so `MartenTurbo::TurboStream.remove(record)`
does the same thing here. The explicit call is what you need once you want a prefix.

Anywhere else, include `MartenTurbo::Identifiable`:

```crystal
class ArticlePresenter
  include MartenTurbo::Identifiable

  def initialize(@article : Article)
  end

  def edit_frame_id
    dom_id(@article, "edit")
  end
end
```
