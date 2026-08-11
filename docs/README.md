<h1>
  <img src="./_media/logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

Marten Turbo adds Turbo Frames, Turbo Streams and Turbo-aware handlers to
[Marten](https://martenframework.com/) applications.

What it gives you:

- `dom_id`, `turbo_frame` and `turbo_stream` template tags
- `MartenTurbo::TurboStream` to build Turbo Stream responses from Crystal
- `RecordCreate`, `RecordUpdate` and `RecordDelete` handlers that answer with a Turbo Stream when
  the request accepts one
- helpers and context producers to tell Turbo, Turbo Frame and Turbo Native requests apart

Turbo itself is not bundled. You install and load `@hotwired/turbo` in your frontend yourself.

Start with the [installation](installation.md), then pick whatever you need:

- [DOM IDs](dom_id.md)
- [Turbo Frames](turbo_frames.md)
- [Turbo Streams](turbo_streams.md)
- [Handlers](handlers.md)
- [Requests and context producers](requests.md)
