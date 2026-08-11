# Turbo Frames

`turbo_frame` renders a `<turbo-frame>` element. It needs an identifier and optionally you can
specify keywords:

```html
{% turbo_frame "articles" src: "/articles", loading: "lazy" %}
  <p>Loading articles…</p>
{% end_turbo_frame %}
```

```html
<turbo-frame id="articles" src="/articles" loading="lazy">
  <p>Loading articles…</p>
</turbo-frame>
```

Keywords follow Marten's template syntax: `name: value`, separated by commas. They're written out
as attributes in the order you give them, so anything Turbo understands on a frame works here.

Pass a model instead of a string and the identifier goes through [`dom_id`](dom_id.md):

```html
{% turbo_frame article %}
  <article>
    <h2>{{ article.title }}</h2>
  </article>
{% end_turbo_frame %}
```

Which will render `article_<article_id>` as tag id.

The tag always opens a block, so it doesn't take a trailing `do` the way `turbo_stream` does.
Close it with `{% end_turbo_frame %}`.

## Reacting to frame requests

Turbo sends a `Turbo-Frame` header when it fetches a page to fill a frame. Register the
`MartenTurbo::Template::ContextProducer::TurboFrame` context producer and you get a
`turbo_frame?` variable to strip the parts of the page the frame won't use:

```html
{% if turbo_frame? %}
  <div>Only shown if request came from a turbo frame</div>
{% endif %}
```

Handlers can check the same thing with `turbo_frame_request?`, and read which frame asked with
`turbo_frame_request_id`. See [requests and context producers](requests.md).
