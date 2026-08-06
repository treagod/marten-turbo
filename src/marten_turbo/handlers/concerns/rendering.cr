require "./streamable"

module MartenTurbo
  module Handlers
    module Concerns
      # Provides the ability to generate turbo stream responses with the content of rendered templates.
      module Rendering
        include Concerns::Streamable

        macro included
          # Returns the configured turbo stream template name.
          class_getter turbo_stream_name : String?
          # Returns the configured turbo template name used when schema validation fails.
          class_getter turbo_invalid_stream_name : String?

          extend MartenTurbo::Handlers::Concerns::Rendering::ClassMethods
        end

        module ClassMethods
          # Allows to configure the turbo stream template that should be rendered by the handler.
          def turbo_stream_name(turbo_stream_name : String?)
            @@turbo_stream_name = turbo_stream_name
          end

          # Allows to configure the turbo stream template rendered when schema validation fails.
          def turbo_invalid_stream_name(turbo_invalid_stream_name : String?)
            @@turbo_invalid_stream_name = turbo_invalid_stream_name
          end
        end

        # Renders the configured turbo stream response, or returns `nil` if none is configured.
        #
        # A turbo stream returned by `#turbo_stream` takes precedence over `#turbo_stream_name`, and `#turbo_stream` is
        # evaluated exactly once.
        def render_turbo_stream?(
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 200,
        ) : Marten::HTTP::Response?
          if stream_obj = turbo_stream
            turbo_stream(stream_obj, status)
          elsif template_name = turbo_stream_name
            turbo_stream(template_name, context: context, status: status)
          end
        end

        # Renders the configured turbo stream response for an invalid schema, or returns `nil` if none is configured.
        #
        # A turbo stream returned by `#turbo_invalid_stream` takes precedence over `#turbo_invalid_stream_name`, and
        # `#turbo_invalid_stream` is evaluated exactly once.
        def render_invalid_turbo_stream?(
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 422,
        ) : Marten::HTTP::Response?
          if stream_obj = turbo_invalid_stream
            turbo_stream(stream_obj, status)
          elsif template_name = turbo_invalid_stream_name
            turbo_stream(template_name, context: context, status: status)
          end
        end

        @[Deprecated("Use `#render_turbo_stream?` instead.")]
        def render_turbo_stream(
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 200,
        )
          render_turbo_stream?(context, status).not_nil!
        end

        @[Deprecated("Use `#render_invalid_turbo_stream?` instead.")]
        def render_invalid_turbo_stream(
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 422,
        )
          render_invalid_turbo_stream?(context, status).not_nil!
        end

        def turbo_stream : MartenTurbo::TurboStream | Nil
          nil
        end

        def turbo_invalid_stream : MartenTurbo::TurboStream | Nil
          nil
        end

        @[Deprecated("Use `#render_turbo_stream?` instead, which resolves and renders in one step.")]
        def turbo_streamable?
          !!(turbo_stream || turbo_stream_name)
        end

        @[Deprecated("Use `#render_invalid_turbo_stream?` instead, which resolves and renders in one step.")]
        def turbo_invalid_streamable?
          !!(turbo_invalid_stream || turbo_invalid_stream_name)
        end

        def turbo_stream_name : String | Nil
          self.class.turbo_stream_name
        end

        def turbo_invalid_stream_name : String | Nil
          self.class.turbo_invalid_stream_name
        end
      end
    end
  end
end
