module MartenTurbo
  module Handlers
    # Provides the ability to generate turbo stream responses with the content of rendered templates.
    module TurboFrame
      # Returns if the current request is a turbo frame request
      def turbo_frame_request?
        !turbo_frame_request_id.nil?
      end

      # Returns the value of the Turbo-Frame header
      def turbo_frame_request_id
        request.headers["Turbo-Frame"]?
      end
    end
  end
end
