# Requests and context producers

Marten Turbo adds three predicates to `Marten::HTTP::Request`:

```crystal
request.turbo?            # accepts text/vnd.turbo-stream.html
request.turbo_frame?      # carries a Turbo-Frame header
request.turbo_native_app? # User-Agent contains "Turbo Native"
```

Handlers that include `MartenTurbo::Handlers::Concerns::Streamable`, which covers all the
[Turbo handlers](handlers.md), get `turbo_request?`, `turbo_frame_request?` and
`turbo_native_request?` for the same checks, plus `turbo_frame_request_id` for the name of the
frame that made the request:

```crystal
class ArticleHandler < Marten::Handler
  include MartenTurbo::Handlers::Concerns::Streamable

  def get
    return render("articles/_article.html") if turbo_frame_request?

    render("articles/show.html")
  end
end
```

`MartenTurbo::Handlers::TurboFrame` exposes just `turbo_frame_request?` and
`turbo_frame_request_id`, for handlers that don't need the streaming parts.

## Context producers

Two [context producers](https://martenframework.com/docs/templates/introduction#using-context-producers)
put the same information into templates. `MartenTurbo::Template::ContextProducer::TurboFrame`
adds `turbo_frame?`, `MartenTurbo::Template::ContextProducer::TurboNative` adds `turbo_native?`:

```crystal
Marten.configure do |config|
  config.templates.context_producers = [
    Marten::Template::ContextProducer::Request,
    MartenTurbo::Template::ContextProducer::TurboFrame,
    MartenTurbo::Template::ContextProducer::TurboNative,
  ]
end
```

With that in place a layout can skip its chrome when it's only going to end up inside a frame:

```html
{% if turbo_frame? %}
  <div>Only shown if request came from a turbo frame</div>
{% endif %}
```

## Turbo Native

`turbo_native?` works the same way and lets you adjust the HTML for requests coming from a
[Turbo Native](https://turbo.hotwired.dev/handbook/native) app:

```html
<body {% if turbo_native? %}class="turbo-native"{% endif %}>
  ...
</body>
```

The detection is a plain `User-Agent` check for the string `Turbo Native`, so the client has to
send a user agent containing it.
