# Turbo Streams

A Turbo Stream tells Turbo to do one thing to one element: append to it, replace it, remove it.
Marten Turbo can build them from a template tag or from Crystal.

## The `turbo_stream` tag

The tag takes an action and a target. Render another template into it with the `template`
keyword:

```html
{% turbo_stream 'append' 'articles' template: 'articles/_article.html' %}
```

```html
<turbo-stream action="append" target="articles">
  <template>
    <!-- content of articles/_article.html -->
  </template>
</turbo-stream>
```

Or add `do` and write the content inline:

```html
{% turbo_stream 'replace' article do %}
  <article id="{% dom_id article %}">
    <h2>{{ article.title }}</h2>
  </article>
{% end_turbo_stream %}
```

The target here is a record, so it goes through [`dom_id`](dom_id.md) and you get
`<turbo-stream action="replace" target="article_1">`.

Actions without content don't need a body:

```html
{% turbo_stream 'remove' article %}
```

```html
<turbo-stream action="remove" target="article_1">
</turbo-stream>
```

Note that the positional arguments are separated by spaces, not commas. Commas only separate
keywords.

## From Crystal

`MartenTurbo::TurboStream` builds the same markup. There's a class method per action: `append`,
`prepend`, `replace`, `update`, `remove`, `before` and `after`.

```crystal
MartenTurbo::TurboStream.remove(article)
MartenTurbo::TurboStream.append("articles", rendered_article)
```

Records are resolved through `dom_id`, strings are used as they are.

A target starting with a dot switches to CSS selector targeting, which lets one action hit
several elements at once:

```crystal
MartenTurbo::TurboStream.remove(".event_123")
MartenTurbo::TurboStream.remove(:".event_123")
```

That renders `targets=".event_123"` instead of `target=`. Same thing works in the tag:

```html
{% turbo_stream 'remove' '.event_123' %}
```

## Several actions in one response

Turbo happily processes more than one stream element per response. Pass a block to `new`:

```crystal
MartenTurbo::TurboStream.new do
  append("articles", rendered_article)
  replace("article_form", rendered_form)
end
```

Chaining works too, if that reads better:

```crystal
MartenTurbo::TurboStream.new
  .append("articles", rendered_article)
  .replace("article_form", rendered_form)
```

Values that end up in the `action`, `target` and `targets` attributes are HTML-escaped. The
content you pass in isn't, since that's the markup Turbo is supposed to insert.

To return one of these from a handler, see [handlers](handlers.md).
