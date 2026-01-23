require "./request_helpers"

module MartenTurbo
  module Handlers
    # Provides the ability to detect Turbo Frame requests outside of the Streamable concern.
    module TurboFrame
      include Concerns::RequestHelpers

      def turbo_frame_request?
        super
      end

      def turbo_frame_request_id
        super
      end
    end
  end
end
