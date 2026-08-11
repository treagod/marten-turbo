<h1>
  <img src="https://raw.githubusercontent.com/treagod/marten-turbo/e317fa4c759ebb61a335d22872a39caf39cfe5cc/docs/_media/logo.svg" height="32" width="32" alt="Marten Turbo Logo">
  <span>Marten Turbo</span>
</h1>

[![GitHub Release](https://img.shields.io/github/v/release/treagod/marten-turbo?style=flat)](https://github.com/treagod/marten-turbo/releases)
[![Marten Turbo Specs](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/specs.yml)
[![QA](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml/badge.svg)](https://github.com/treagod/marten-turbo/actions/workflows/qa.yml)

Marten Turbo adds Turbo Frames, Turbo Streams and Turbo-aware handlers to
[Marten](https://martenframework.com/) applications.

It gives you three template tags (`dom_id`, `turbo_frame`, `turbo_stream`), a Crystal API to
build Turbo Stream responses, and versions of Marten's generic record handlers that answer with a
Turbo Stream when the browser asks for one.

This is the server side only. Turbo itself still needs to be installed and loaded in your
frontend, for example through [marten-importmap](https://github.com/treagod/marten-importmap).

## Requirements

Marten 0.6.0 or later. The specs run against Crystal 1.15, 1.16 and 1.17.

## Installation

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

The template tags are registered when the app is set up, so `MartenTurbo::App` has to be part of
your `installed_apps`:

```crystal
Marten.configure do |config|
  config.installed_apps = [
    MartenTurbo::App,
    # Other applications...
  ]
end
```

Skip that step and every template using `dom_id`, `turbo_frame` or `turbo_stream` fails with an
unknown tag error.

## Example

A handler that creates an article and answers Turbo requests with a stream:

```crystal
class ArticleCreateHandler < MartenTurbo::Handlers::RecordCreate
  model Article
  schema ArticleSchema
  template_name "articles/create.html"
  turbo_stream_name "articles/create.turbo_stream.html"
  success_route_name "articles"
end
```

`articles/create.turbo_stream.html` gets the new record as `record`:

```html
<turbo-stream action="append" target="articles">
  <div id="{% dom_id record %}">{{ record.title }}</div>
</turbo-stream>
```

Regular form submits still get the redirect to `articles`. Only requests that accept
`text/vnd.turbo-stream.html` get the stream.

## Documentation

The full documentation lives at
[treagod.github.io/marten-turbo](https://treagod.github.io/marten-turbo/), or under
[`docs/`](docs/) in this repository.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/treagod/marten-turbo/issues). Run `crystal spec` and
`crystal tool format` before opening a PR.

## License

MIT. See [LICENSE](LICENSE).
