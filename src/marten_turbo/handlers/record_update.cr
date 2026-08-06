require "./concerns/rendering"

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
      include Concerns::Rendering

      def process_valid_schema
        return super unless request.turbo?

        save_record

        render_turbo_stream?(context) || Marten::HTTP::Response::Found.new(success_url)
      end

      def process_invalid_schema
        return super unless turbo_request?

        render_invalid_turbo_stream?(context) || super
      end
    end
  end
end
