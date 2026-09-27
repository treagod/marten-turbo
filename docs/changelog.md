# Changelog

All notable changes to this project will be documented in this file.

## Marten Turbo 0.4.0
**2026-09-27**

### Changed
- Marten 0.7 is now supported alongside Marten 0.6, with CI coverage through Crystal 1.21.

### Fixed
- `Request#turbo?` no longer treats `*/*` as a Turbo Stream request. Regular browser form submissions (and requests without an `Accept` header) get the redirect again instead of a Turbo Stream response.

## Marten Turbo 0.3.1
**2026-08-14**

### Added
- `turbo_invalid_stream_name` and `turbo_invalid_stream` support on Turbo handlers to render validation errors over Turbo Streams.
- `#render_turbo_stream?` and `#render_invalid_turbo_stream?`, which resolve and render a Turbo Stream response in a single step and return `nil` when none is configured.
- Dot-prefixed string and symbol targets now automatically emit selector-based Turbo Stream actions, for example `TurboStream.remove(".event_123")` or `TurboStream.remove(:".event_123")`.

### Changed
- `MartenTurbo::Handlers::Concerns::Streamable` now provides request helper methods alongside private `turbo_stream` responders.
- `RecordCreate`, `RecordUpdate` and `RecordDelete` now delegate record persistence to their Marten counterparts instead of reimplementing it. Custom `#prepare_record_attributes` and `#save_record` implementations are now respected, and `RecordCreate#record` correctly exposes the created record.
- Marten is now constrained to `~> 0.6.0`, and Crystal 1.19 or later is required.
- `MartenTurbo::Handlers::Concerns::Streamable` now includes `MartenTurbo::Identifiable`, so `dom_id` is available in every handler that includes the concern.
- A handler's `#turbo_stream` and `#turbo_invalid_stream` methods are now evaluated at most once per request. They used to be called once to check whether a Turbo Stream response was possible and again to render it.

### Fixed
- Values written into generated HTML attributes are now HTML-escaped: Turbo Stream action names and targets, Turbo Frame identifiers and their additional attributes, and the output of the `dom_id` tag. Turbo Stream template content and Turbo Frame body content are still rendered as raw HTML.
- The docs now mention that `MartenTurbo::App` has to be added to `installed_apps`, and cover the parts of the API that were missing.

### Removed
- The empty `#render(turbo_stream : TurboStream, context)` overload on `MartenTurbo::Handlers::Concerns::Rendering`, which had no behavior and no callers.

### Deprecated
- `#render_turbo_stream` and `#render_invalid_turbo_stream` in favour of `#render_turbo_stream?` and `#render_invalid_turbo_stream?`.
- `#turbo_streamable?` and `#turbo_invalid_streamable?`. Calling them evaluates `#turbo_stream` an extra time; use the `?` renderers and fall back on their `nil` result instead.

## Marten Turbo 0.3.0
**2025-04-01**

### Added
- `MartenTurbo::TurboStream.new` now accepts a block which can be used to create multiple stream tags.
- `turbo_frame` tag
- `turbo_stream` response helper
- `MartenTurbo::Template::ContextProducer::TurboFrame` context producer

### Changed
- `dom_id` is now more general and accepts `Marten::Model` or anything that responds to `#to_s`.

### Deprecated
- Renamed `create_dom_id` to `dom_id` to better fit the template tag naming convention.
- Renamed `MartenTurbo::Handlers::TurboStreamable` to `MartenTurbo::Handlers::Concerns::Rendering`.

## Marten Turbo 0.2.1
**2024-06-17**

### Fixed
- `TurboStream` can now correctly create target IDs from a `Marten::Model`.

### Breaking Changes
- `MartenTurbo::Handlers::TurboStreamable` was renamed to `MartenTurbo::Handlers::Concerncs::Rendering`

## Marten Turbo 0.2.0
**2024-06-13**

### Added
- New `MartenTurbo::TurboStream` class: Introduced a new `TurboStream` class to streamline the creation of Turbo Streams. This class provides a convenient API to generate various Turbo Stream actions.
- Turbo Handlers Enhancement: Turbo handlers now support a `turbo_stream` method. This method should return a string that will be rendered instead of a template. It takes precedence over the `turbo_stream_name` attribute, offering greater flexibility in handling Turbo Stream responses.
- `MartenTurbo::Handlers::TurboFrame` concern: Added a new concern, TurboFrame, which can be included to track Turbo-Frame requests. This enhancement simplifies the detection and handling of Turbo Frame specific requests. This adds the `turbo_frame_request?` and `turbo_frame_request_id` methods to your handler.

### Changed
- `RecordDelete` Enhancement: The `RecordDelete` handler now forwards a `DELETE` request to post, improving consistency and reliability in handling delete operations.

### Breaking Changes
- End Tag Update: The end tag for Turbo Streams has been updated from `{% end_turbostream %}` to `{% end_turbo_stream %}`. This change aligns the syntax with Marten’s end tags, enhancing readability and consistency across the codebase.

## Marten Turbo 0.1.1
**2024-03-20**

### Changed
- Updated shard name.

## Marten Turbo 0.1.0
**2024-03-20**

### Added
- Initial release of Marten Turbo.
- Handlers for record creation, updating, and deletion with Turbo Streams.
