module MartenTurbo
  module Handlers
    # Provides the ability to generate turbo stream responses with the content of rendered templates.
    module TurboStreamable
      macro included
        # Returns the configured turbo stream template name.
        class_getter turbo_stream_name : String?

        extend MartenTurbo::Handlers::TurboStreamable::ClassMethods
      end

      module ClassMethods
        # Allows to configure the turbo stream template that should be rendered by the handler.
        def turbo_stream_name(turbo_stream_name : String?)
          @@turbo_stream_name = turbo_stream_name
        end
      end

      def render_turbo_stream(
        context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
        status : ::HTTP::Status | Int32 = 200
      )
        render(turbo_stream_name.not_nil!, context: context, status: status, content_type: "text/vnd.turbo-stream.html")
      end

      def turbo_stream_name : String | Nil
        self.class.turbo_stream_name
      end
    end
  end
end
