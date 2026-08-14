# Installation

Marten Turbo 0.3.x needs Marten 0.6.x and Crystal 1.19 or later.

Add the shard to your `shard.yml`:

```yaml
dependencies:
  marten_turbo:
    github: treagod/marten-turbo
```

Run `shards install`, then require it in `src/project.cr`:

```crystal
require "marten_turbo"
```

Requiring the shard isn't enough on its own. The template tags are registered while the app is
set up, so `MartenTurbo::App` has to be listed in your `installed_apps`:

```crystal
Marten.configure do |config|
  config.installed_apps = [
    MartenTurbo::App,
    # Other applications...
  ]
end
```

Without it, any template using `dom_id`, `turbo_frame` or `turbo_stream` fails with an unknown
tag error.

## Turbo itself

Marten Turbo only covers the server side. It renders `<turbo-frame>` and `<turbo-stream>`
elements and sets the right content type, but the JavaScript that reacts to them is still
[`@hotwired/turbo`](https://turbo.hotwired.dev/handbook/installing), which you install and load
through your own asset setup. [marten-importmap](https://github.com/treagod/marten-importmap) is
one way to do that.

## Context producers

If you want to know inside a template whether the request came from a Turbo Frame or a Turbo
Native app, register the matching context producers. See
[requests and context producers](requests.md).
