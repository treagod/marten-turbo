require "./concerns/turbo_streamable"

module MartenTurbo
  module Handlers
    # Handler for deleting model records, with optional Turbo Stream support.
    #
    # This handler extends `Marten::Handlers::RecordDelete`, enabling seamless Turbo Stream
    # functionality. For Turbo Stream requests, if `turbo_stream_name` is set, the handler
    # renders that template. This allows dynamic deletion confirmations and partial page updates.
    #
    # If no Turbo Stream request is present or no `turbo_stream_name` is defined, the
    # handler behaves identically to its parent class, `Marten::Handlers::RecordDelete`.
    #
    # ```
    # class MyTurboDeleteHandler < MartenTurbo::Handlers::RecordDelete
    #   model MyModel
    #   template_name "my_delete.html"
    #   turbo_stream_name "my_delete.turbo_stream.html"
    #   success_route_name "my_delete_success"
    # end
    # ```
    class RecordDelete < Marten::Handlers::RecordDelete
      include TurboStreamable

      def post
        perform_deletion

        if request.turbo? && turbo_stream_name
          render_turbo_stream context
        else
          Marten::HTTP::Response::Found.new(success_url)
        end
      end
    end
  end
end
