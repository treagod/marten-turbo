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

          extend MartenTurbo::Handlers::Concerns::Rendering::ClassMethods
        end

        module ClassMethods
          # Allows to configure the turbo stream template that should be rendered by the handler.
          def turbo_stream_name(turbo_stream_name : String?)
            @@turbo_stream_name = turbo_stream_name
          end
        end

        def render_turbo_stream(
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 200,
        )
          if stream_obj = turbo_stream
            turbo_stream(stream_obj, status)
          else
            turbo_stream(turbo_stream_name.not_nil!, context: context, status: status)
          end
        end

        def render(
          turbo_stream : TurboStream,
          context,
        )
        end

        def turbo_stream : MartenTurbo::TurboStream | Nil
          nil
        end

        def turbo_streamable?
          !!(turbo_stream || turbo_stream_name)
        end

        def turbo_stream_name : String | Nil
          self.class.turbo_stream_name
        end
      end
    end
  end
end
