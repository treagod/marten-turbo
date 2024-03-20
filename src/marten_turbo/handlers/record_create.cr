module MartenTurbo
  module Handlers
    # Handler for creating model records, with optional Turbo Stream support.
    #
    # This handler extends the functionality of `Marten::Handlers::RecordCreate` to provide seamless
    # integration with Turbo Streams. Upon receiving a Turbo Stream request, if a
    # `turbo_stream_name` has been configured, the handler will render the specified template.
    # This allows for dynamic form updates and partial page replacements within your web application.
    #
    # If no Turbo Stream request is detected or no `turbo_stream_name` is set, the handler
    # behaves identically to its parent class, `Marten::Handlers::RecordCreate`.
    #
    # ```
    # class MyFormHandler < MartenTurbo::Handlers::RecordCreate
    #   model MyModel
    #   schema MyFormSchema
    #   template_name "my_form.html"
    #   turbo_stream_name "my_form.turbo_stream.html"
    #   success_route_name "my_form_success"
    # end
    # ```
    class RecordCreate < Marten::Handlers::RecordCreate
      class_getter turbo_stream_name : String?
      class_getter record_context_name : String = "record"

      def self.record_context_name(name : String | Symbol)
        @@record_context_name = name.to_s
      end

      def process_valid_schema
        self.record = model.new(schema.validated_data)
        self.record.try(&.save!)

        if request.turbo? && turbo_stream_name
          context[self.class.record_context_name] = record
          render_turbo_stream context
        else
          Marten::HTTP::Response::Found.new success_url
        end
      end

      def render_turbo_stream(
        context : Hash | NamedTuple | Nil | Marten::Template::Context = nil,
        status : ::HTTP::Status | Int32 = 200
      )
        render(turbo_stream_name.not_nil!, context: context, status: status)
      end

      def self.turbo_stream_name(turbo_stream_name : String?)
        @@turbo_stream_name = turbo_stream_name
      end

      def turbo_stream_name : String | Nil
        self.class.turbo_stream_name
      end
    end
  end
end
