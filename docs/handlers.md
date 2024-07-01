# Handlers

Marten Turbo extends the core [Marten generic handlers](https://martenframework.com/docs/handlers-and-http/reference/generic-handlers), streamlining the integration of Turbo Streams into your application.

## Core Concepts

* **Dedicated Turbo Handlers:**  Marten Turbo introduces `MartenTurbo::Handlers::RecordCreate`,  `MartenTurbo::Handlers::RecordUpdate`, and `MartenTurbo::Handlers::RecordDelete`, which extend their counterparts from the Marten Framework.
* **Turbo Stream Rendering:**  The `turbo_stream_name`  class method allows you to specify a separate template that renders as a Turbo Stream for seamless dynamic updates.

## Record Creation

Use the `MartenTurbo::Handlers::RecordCreate` handler to create new records.

```ruby
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

## Record Update

Use the `MartenTurbo::Handlers::RecordUpdate` handler to update existing records.

```ruby
class ArticleUpdateHandler < MartenTurbo::Handlers::RecordUpdate
  model Article
  schema ArticleSchema
  template_name "articles/update.html"
  turbo_stream_name "articles/update.turbo_stream.html"
  success_route_name "articles"
end
```

## Record Deletion

Use the `MartenTurbo::Handlers::RecordDelete` handler for deleting records.

```ruby
class ArticleDeleteHandler < MartenTurbo::Handlers::RecordDelete
  model Article
  template_name "articles/delete.html"
  turbo_stream_name "articles/delete.turbo_stream.html"
  success_route_name "articles"
end
```
