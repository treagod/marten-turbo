module MartenTurbo
  module Handlers
    module Concerns
      # Adds convenience helpers to check for Turbo-specific request characteristics.
      module RequestHelpers
        private def turbo_request?
          request.turbo?
        end

        private def turbo_native_request?
          request.turbo_native_app?
        end

        private def turbo_frame_request?
          request.turbo_frame?
        end

        private def turbo_frame_request_id
          request.headers["Turbo-Frame"]?
        end
      end
    end
  end
end
