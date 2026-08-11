# Handlers

Marten Turbo ships Turbo-aware versions of Marten's generic record handlers. They behave exactly
like their Marten counterparts, except that a successful request answers with a Turbo Stream
instead of the redirect when the browser asked for one.

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

`turbo_stream_name` is the only thing added to a regular `Marten::Handlers::RecordCreate` here.
Requests that accept `text/vnd.turbo-stream.html` render that template; everything else gets the
redirect to `articles`, which is why `success_route_name` is still required.

The created record is in the stream template context as `record`:

```html
<turbo-stream action="append" target="articles">
  <article id="{% dom_id record %}">{{ record.title }}</article>
</turbo-stream>
```

Use `record_context_name "article"` on the handler if you'd rather call it something else.

`MartenTurbo::Handlers::RecordUpdate` works the same way and exposes the updated record under the
same name. `MartenTurbo::Handlers::RecordDelete` has no schema, and its stream template gets the
record that was just deleted.

## Building the stream in Crystal

For short streams a template file is often overkill. Define `#turbo_stream` instead:

```crystal
class ArticleDeleteHandler < MartenTurbo::Handlers::RecordDelete
  model Article
  template_name "articles/delete.html"
  success_route_name "articles"

  def turbo_stream
    MartenTurbo::TurboStream.remove(record)
  end
end
```

If both `#turbo_stream` and `turbo_stream_name` are set, `#turbo_stream` wins. It's called once
per request, so it's fine to render templates or hit the database in there.

## Persistence stays Marten's

Record creation, updating and deletion are delegated to the parent Marten handler, so the usual
extension points keep working. Override `#prepare_record_attributes` to change what goes into the
record:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  # ...
  def prepare_record_attributes
    super.merge({"author_id" => request.session["user_id"]})
  end
end
```

`#save_record` can be overridden the same way, `#record` gives you the record after a successful
save, and callbacks fire in their normal order.

## Validation errors

A failed schema validation renders `template_name` with status 422 by default, which throws a
full page at a Turbo request that was only meant to update a form. `turbo_invalid_stream_name`
handles that case:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  turbo_invalid_stream_name "articles/create_errors.turbo_stream.html"
  success_route_name "articles"
end
```

The error template can swap just the form:

```html
<turbo-stream action="replace" target="article_form">
  {% include "articles/form.html" %}
</turbo-stream>
```

The response keeps the 422 status. Non-Turbo requests still render the regular HTML view.

There's a `#turbo_invalid_stream` method for the Crystal side too:

```crystal
def turbo_invalid_stream
  form = Marten.templates.get_template("articles/_form.html").render(context)

  MartenTurbo::TurboStream.replace("article_form", form)
end
```

`MartenTurbo::Handlers::RecordUpdate` supports both the same way.

## Turbo Streams from a regular handler

Any Marten handler can return a Turbo Stream by including
`MartenTurbo::Handlers::Concerns::Streamable`. That gives you a `turbo_stream` responder, the
request helpers and `dom_id`:

```crystal
class ArticleArchiveHandler < Marten::Handler
  include MartenTurbo::Handlers::Concerns::Streamable

  def post
    article = Article.get!(pk: params["pk"])
    article.update!(archived: true)

    turbo_stream(MartenTurbo::TurboStream.remove(dom_id(article)))
  end
end
```

`turbo_stream` takes a `MartenTurbo::TurboStream`, a template name, or a block:

```crystal
def post
  turbo_stream do
    remove("article_1")
    append("notices", "<div>Article archived</div>")
  end
end
```

A status code can be passed as the last argument, for example
`turbo_stream(stream, 422)`. Responses go out as `text/vnd.turbo-stream.html`.

Handlers that configure `turbo_stream_name` but do their own branching can use
`render_turbo_stream?`. It resolves the configured stream and renders it in one step, and returns
`nil` when nothing is configured, so a fallback with `||` works:

```crystal
def post
  render_turbo_stream?(context) || redirect(reverse("articles"))
end
```

`render_invalid_turbo_stream?` does the same for `turbo_invalid_stream_name` and
`#turbo_invalid_stream`, with a 422 status.
