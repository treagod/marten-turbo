module MartenTurbo
  module Handlers
    # Handler for updating model records with optional Turbo Stream support.
    #
    # This handler extends `Marten::Handlers::RecordUpdate` for Turbo Stream integration. Upon a Turbo
    # Stream request, if `turbo_stream_name` is configured, it renders that template. This
    # enables dynamic form updates and partial page replacements.
    #
    # If no Turbo Stream request is detected or no `turbo_stream_name` is set, the handler
    # behaves identically to its parent class, `Marten::Handlers::RecordUpdate`.
    #
    # ```
    # class MyTurboUpdateHandler < MartenTurbo::Handlers::RecordUpdate
    #   model MyModel
    #   schema MyFormSchema
    #   template_name "my_form.html"
    #   turbo_stream_name "my_form_turbo.html"
    #   success_route_name "my_form_success"
    # end
    # ```
    class RecordUpdate < Marten::Handlers::RecordUpdate
      class_getter turbo_stream_name : String?

      def process_valid_schema
        record.update!(schema.validated_data.select(model.fields.map(&.id)))

        if request.turbo? && turbo_stream_name
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
