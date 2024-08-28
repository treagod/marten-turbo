# Usage

## Template Helpers

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

## Handlers

Marten Turbo extends the generic Marten handlers to work seamlessly with Turbo Streams. Here’s how to use them for common tasks.

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

You can also adjust your HTML templates based on whether the request is from a Turbo Native app:

```html
<body {% if turbo_native? %}class="turbo-native"{% endif %}>
  <!-- Your content here -->
</body>
```

This allows you to tailor your application’s behavior and appearance specifically for Turbo Native applications.
