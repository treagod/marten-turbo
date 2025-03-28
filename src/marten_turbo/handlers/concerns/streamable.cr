module MartenTurbo
  module Handlers
    module Concerns
      module Streamable
        def turbo_stream(
          template_name : String,
          context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
          status : ::HTTP::Status | Int32 = 200,
        )
          render(template_name, context, TURBO_CONTENT_TYPE, status)
        end

        def turbo_stream(
          stream : MartenTurbo::TurboStream,
          status : ::HTTP::Status | Int32 = 200,
        )
          respond(stream.to_s, TURBO_CONTENT_TYPE, status)
        end

        def turbo_stream(status : ::HTTP::Status | Int32 = 200, &)
          stream = TurboStream.new

          with stream yield

          turbo_stream(stream, status)
        end
      end
    end
  end
end
