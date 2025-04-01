# Changelog

All notable changes to this project will be documented in this file.

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
