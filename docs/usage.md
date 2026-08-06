# Usage

## Template Helpers

### `turbo_frame`

The `turbo_frame` helper renders a Turbo Frame. It needs an identifier and optionally you can specify keywords:

```html
{% turbo_frame 'tasks' src="/tasks" loading="lazy" %}
  <p>Loading tasks…</p>
{% end_turbo_frame %}
```

You can also pass a Marten model to `turbo_frame`

```html
{% turbo_frame article %}
  <article>
    <h2>{{ article.title }}</h2>
    …
  </article>
{% end_turbo_frame %}
```

Which will render `article_<aritcle_id>` as tag id.

You can further customize responses triggered by a turbo frame when using the [context producer](https://martenframework.com/docs/templates/introduction#using-context-producers) `MartenTurbo::Template::ContextProducer::TurboFrame`. This provides you a handy `turbo_frame?` variable:

```html
{% if turbo_frame? %}
  <div>Only shown if request came from a turbo frame</div>
{% end_if %}
```

### `dom_id`

Marten Turbo provides a `dom_id` template helper, which simplifies generating unique DOM IDs for your elements. This is especially useful when working with Turbo Streams.

### Example Usage

To generate a unique DOM ID for an `article` object, you can use the following syntax in your template:

```html
<div id="{% dom_id article %}"> <!-- Generates an ID like article_1, article_2, etc. -->
  <!-- Your content here -->
</div>
```

If the article object is new and does not yet have an ID, the `dom_id` helper will generate an ID like new_article.

### Namespacing

The `dom_id` will respect the namespace of your model. For example, if your `Article` model is within a Blogging namespace, the generated ID would be blogging_article_1.

```html
<div id="{% dom_id article %}">
  <!-- Content -->
</div>
```

## Turbo Stream Helpers

Marten Turbo also provides helpers to work with Turbo Streams, allowing you to update parts of your page dynamically.

### Example: Appending Content

To append content to an existing element with the ID articles, you can use the turbo_stream helper like this:

```html
{% turbo_stream 'append' "articles" do %}
  <div class="{% dom_id article %}">
    {{ article.name }}
  </div>
{% end_turbo_stream %}
````

This will generate the following HTML:

```html
<turbo-stream action="append" target="articles">
  <template>
    <div class="article_1">
      My First Article
    </div>
  </template>
</turbo-stream>
```

### Example: Removing Content

To remove an element corresponding to a specific article, you can use:

```html
{% turbo_stream 'remove' article %}
```

This will generate:

```html
<turbo-stream action="remove" target="article_1">
</turbo-stream>
```

To remove multiple elements via CSS selector, use a dot-prefixed string target:

```html
{% turbo_stream 'remove' '.event_123' %}
```

This will generate:

```html
<turbo-stream action="remove" targets=".event_123">
</turbo-stream>
```

From Crystal handlers, dot-prefixed string or symbol targets automatically use selector targeting:

```crystal
MartenTurbo::TurboStream.remove(".event_123")
MartenTurbo::TurboStream.remove(:".event_123")
```

## Handlers

Marten Turbo extends the generic Marten handlers to work seamlessly with Turbo Streams. Here’s how to use them for common tasks.

These handlers delegate record persistence to their Marten counterparts and only replace the success redirect with a Turbo Stream response when one is configured. Everything the generic Marten handlers offer therefore keeps working: `#prepare_record_attributes` and `#save_record` can be overridden to customize how records are built and persisted, `#record` exposes the created or updated record, and the regular handler callbacks run in their usual order.

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  # ...
  def prepare_record_attributes
    super.merge({"author_id" => request.session["user_id"]})
  end
end
```

### Record creation

To create a record and handle Turbo Stream responses, use the `MartenTurbo::Handlers::RecordCreate` handler:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

If you want Turbo requests to stay inside the frame when the schema is invalid, add an error stream template or override:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  # ...
  turbo_stream_name "articles/create.turbo_stream.html"
  turbo_invalid_stream_name "articles/create_errors.turbo_stream.html"
end
```

Inside `articles/create_errors.turbo_stream.html` you can re-render the form (or only the error block) and let Turbo replace the form fragment:

```html
<turbo-stream action="replace" target="article_form">
  {% include "articles/form.html" %}
</turbo-stream>
```

### Record Update

Similarly, to update a record:

```crystal
class ArticleUpdateHandler < MartenTurbo::Handlers::RecordUpdate
  model Article
  schema ArticleSchema
  template_name "articles/update.html"
  turbo_stream_name "articles/update.turbo_stream.html"
  success_route_name "articles"
end
```

Record update handlers support the same pattern via `turbo_invalid_stream_name` or a `def turbo_invalid_stream` override:

```crystal
class ArticleUpdateHandler < MartenTurbo::Handlers::RecordUpdate
  # ...
  def turbo_invalid_stream
    MartenTurbo::TurboStream.replace(dom_id(record || schema), render("articles/form.html"))
  end
end
```

### Record deletion

For record deletion, you could define a custom `turbo_stream` method to avoid creating a single file for a short stream tag:

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

## Turbo Native

Marten Turbo allows you to detect requests from Turbo Native applications easily.

### Checking for Turbo Native Requests

You can check if a request comes from a Turbo Native app by using the `request.turbo_native_app?` method:

```crystal
if request.turbo_native_app?
  # Handle Turbo Native request
end
```

With the [context producer](https://martenframework.com/docs/templates/introduction#using-context-producers) `MartenTurbo::Template::ContextProducer::TurboNative` the `turbo_native?` tag can be used within your template:

```html
<body {% if turbo_native? %}class="turbo-native"{% endif %}>
  <!-- Your content here -->
</body>
```

This allows you to tailor your application’s behavior and appearance specifically for Turbo Native applications.
