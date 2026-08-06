# Turbo Error Handling

Turbo Streams make form submissions feel instant, but only if validation errors can be delivered inside the same frame. Marten Turbo 0.3.1 adds first-class support for that flow through `turbo_invalid_stream_name` and `turbo_invalid_stream`.

## RecordCreate

Configure two templates:

```crystal
class Articles::CreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  turbo_invalid_stream_name "articles/create_errors.turbo_stream.html"
end
```

`articles/create_errors.turbo_stream.html` can swap just the form errors:

```html
<turbo-stream action="replace" target="article_form">
  {% include "articles/form.html" %}
</turbo-stream>
```

On success, the usual turbo stream template runs. On failure, Marten Turbo returns HTTP 422 with the error template while non‑Turbo requests still render the original HTML view.

## RecordUpdate

The pattern is identical:

```crystal
class Articles::UpdateHandler < MartenTurbo::Handlers::RecordUpdate
  model Article
  schema ArticleSchema
  template_name "articles/update.html"
  turbo_stream_name "articles/update.turbo_stream.html"
  turbo_invalid_stream_name "articles/update_errors.turbo_stream.html"
end
```

Or skip the template and build the stream inline:

```crystal
def turbo_invalid_stream
  MartenTurbo::TurboStream.new do
    replace("article_edit_frame", render("articles/edit.html", status: 422))
  end
end
```

## Request Helpers

Handlers now gain `turbo_request?`, `turbo_frame_request?`, and `turbo_native_request?` through the `Streamable` concern, so you can branch without referencing `request` directly:

```crystal
return render_invalid_turbo_stream?(context) if turbo_request?
```

`render_invalid_turbo_stream?` (and its `render_turbo_stream?` counterpart) resolves and renders in a single step: it returns the Turbo Stream response when one is configured and `nil` otherwise, so you can fall back with `||`. Your `#turbo_invalid_stream` method is evaluated exactly once.

## Use Cases

1. **Inline form errors in modals** – combine a `turbo-frame` modal with `turbo_invalid_stream_name` to keep the modal open when validation fails.
2. **Multi-step wizards** – stream error messages into a sidebar while leaving context intact.
3. **Mobile-friendly flows** – Turbo Native clients benefit from the same APIs; check `turbo_native_request?` to tweak responses per platform.
4. **Custom validation summaries** – override `turbo_invalid_stream` to render summaries or analytics hooks without adding templates.
