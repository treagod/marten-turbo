# Handlers

Marten Turbo provides enhanced handlers that streamline record creation, updates, and deletions in your Marten application, with built-in Turbo Stream support for seamless dynamic updates to the user interface. These handlers are defined under the namespace `MartenTurbo::Handlers`.

## Core Handlers

### RecordCreateHandler

* Handles the creation of new records.
* Automatically generates and renders Turbo Stream responses on successful creation.
* Provides configuration options for:
    * `schema` (the associated Marten schema)
    * `template_name` (the template to render on success)
    * `turbo_stream_name` (the Turbo Stream template to render on success)
    * `success_route_name` (the route to redirect to on success)

### RecordUpdateHandler

* Handles updates to existing records.
* Supports generating Turbo Stream responses on successful updates.
* Provides the same configuration options as `RecordCreateHandler`.

### RecordDeleteHandler

* Handles record deletion.
* Can generate Turbo Stream responses to remove elements from the DOM upon successful deletion.
* Shares the same configuration options as the other handlers.

## Examples

```ruby
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

```ruby
class ArticleCreateHandler < MartenTurbo::Handlers::RecordUpdate
  model Article
  schema ArticleSchema
+   template_name "articles/update.html"
  turbo_stream_name "articles/update.turbo_stream.html"
  success_route_name "articles"
end
```

```ruby
class ArticleCreateHandler < MartenTurbo::Handlers::RecordDelete
  model Article
  template_name "articles/delete.html"
  turbo_stream_name "articles/delete.turbo_stream.html"
  success_route_name "articles"
end
```
